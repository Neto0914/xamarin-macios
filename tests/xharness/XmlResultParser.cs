using System;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Linq;

namespace xharness {
	public static class XmlResultParser {

		public enum Jargon {
			TouchUnit,
			NUnitV2,
			NUnitV3,
			xUnit,
			Missing,
		}

		// test if the file is valid xml, or at least, that can be read it.
		public static bool IsValidXml (string path, out Jargon type)
		{
			type = Jargon.Missing;
			if (!File.Exists (path))
				return false;

			using (var stream = File.OpenText (path)) {
				string line;
				while ((line = stream.ReadLine ()) != null) { // special case when get got the tcp connection
					if (line.Contains ("ping"))
						continue;
					if (line.Contains ("test-run")) { // first element of the NUnitV3 test collection
						type = Jargon.NUnitV3;
						return true;
					}
					if (line.Contains ("TouchUnitTestRun")) {
						type = Jargon.TouchUnit;
						return true;
					}
					if (line.Contains ("nunit-version")) {
						type = Jargon.NUnitV2;
						return true;
					}
					if (line.Contains ("xUnit")) {
						type = Jargon.xUnit;
						return true;
					}
				}
			}
			return false;
		}

		static (string resultLine, bool failed) ParseNUnitV3 (StreamReader stream, StreamWriter writer)
		{
			long testcasecount, passed, failed, inconclusive, skipped;
			bool failedTestRun = false; // result = "Failed"
			testcasecount = passed = failed = inconclusive = skipped = 0L;

			using (var reader = XmlReader.Create (stream)) {
				while (reader.Read ()) {
					if (reader.NodeType == XmlNodeType.Element && reader.Name == "test-run") {
						long.TryParse (reader ["testcasecount"], out testcasecount);
						long.TryParse (reader ["passed"], out passed);
						long.TryParse (reader ["failed"], out failed);
						long.TryParse (reader ["inconclusive"], out inconclusive);
						long.TryParse (reader ["skipped"], out skipped);
						switch (reader["result"]) {
						case "Failed":
							failedTestRun = true;
							break;
						default:
							failedTestRun = false;
							break;
						}
					}
					if (reader.NodeType == XmlNodeType.Element && reader.Name == "test-suite" && (reader ["type"] == "TestFixture" || reader ["type"] == "ParameterizedFixture")) {
						var testCaseName = reader ["fullname"];
						writer.WriteLine (testCaseName);
						var time = reader.GetAttribute ("time") ?? "0"; // some nodes might not have the time :/
												// get the first node and then move in the siblings of the same type
						reader.ReadToDescendant ("test-case");
						do {
							if (reader.Name != "test-case")
								break;
							// read the test cases in the current node
							var status = reader ["result"];
							switch (status) {
							case "Passed":
								writer.Write ("\t[PASS] ");
								break;
							case "Skipped":
								writer.Write ("\t[IGNORED] ");
								break;
							case "Error":
							case "Failed":
								writer.Write ("\t[FAIL] ");
								break;
							case "Inconclusive":
								writer.Write ("\t[INCONCLUSIVE] ");
								break;
							default:
								writer.Write ("\t[INFO] ");
								break;
							}
							writer.Write (reader ["name"]);
							if (status == "Failed") { //  we need to print the message
								reader.ReadToDescendant ("failure");
								reader.ReadToDescendant ("message");
								writer.Write ($" : {reader.ReadElementContentAsString ()}");
								reader.ReadToNextSibling ("stack-trace");
								writer.Write ($" : {reader.ReadElementContentAsString ()}");
							}
							if (status == "Skipped") { // nice to have the skip reason
								reader.ReadToDescendant ("reason");
								reader.ReadToDescendant ("message");
								writer.Write ($" : {reader.ReadElementContentAsString ()}");
							}
							// add a new line
							writer.WriteLine ();
						} while (reader.ReadToNextSibling ("test-case"));
						writer.WriteLine ($"{testCaseName} {time} ms");
					}
				}
			}
			var resultLine = $"Tests run: {testcasecount} Passed: {passed} Inconclusive: {inconclusive} Failed: {failed} Ignored: {skipped + inconclusive}";
			return (resultLine, failedTestRun);
		}

		static (string resultLine, bool failed) ParseTouchUnitXml (StreamReader stream, StreamWriter writer)
		{
			long total, errors, failed, notRun, inconclusive, ignored, skipped, invalid;
			total = errors = failed = notRun = inconclusive = ignored = skipped = invalid = 0L;

			using (var reader = XmlReader.Create (stream)) {
				while (reader.Read ()) {
					if (reader.NodeType == XmlNodeType.Element && reader.Name == "test-results") {
						long.TryParse (reader ["total"], out total);
						long.TryParse (reader ["errors"], out errors);
						long.TryParse (reader ["failures"], out failed);
						long.TryParse (reader ["not-run"], out notRun);
						long.TryParse (reader ["inconclusive"], out inconclusive);
						long.TryParse (reader ["ignored"], out ignored);
						long.TryParse (reader ["skipped"], out skipped);
						long.TryParse (reader ["invalid"], out invalid);
					}

					if (reader.NodeType == XmlNodeType.Element && reader.Name == "TouchUnitExtraData") {
						// move fwd to get to the CData
						if (reader.Read ())
							writer.Write (reader.Value);
					}
				}
			}
			var passed = total - errors - failed - notRun - inconclusive - ignored - skipped - invalid;
			var resultLine = $"Tests run: {total} Passed: {passed} Inconclusive: {inconclusive} Failed: {failed + errors} Ignored: {ignored + skipped + invalid}";
			return (resultLine, total == 0 || errors != 0 || failed != 0);
		}

		static (string resultLine, bool failed) ParseNUnitXml (StreamReader stream, StreamWriter writer)
		{
			long total, errors, failed, notRun, inconclusive, ignored, skipped, invalid;
			total = errors = failed = notRun = inconclusive = ignored = skipped = invalid = 0L;
			XmlReaderSettings settings = new XmlReaderSettings ();
			settings.ValidationType = ValidationType.None;
			using (var reader = XmlReader.Create (stream, settings)) {
				while (reader.Read ()) {
					if (reader.NodeType == XmlNodeType.Element && reader.Name == "test-results") {
						long.TryParse (reader ["total"], out total);
						long.TryParse (reader ["errors"], out errors);
						long.TryParse (reader ["failures"], out failed);
						long.TryParse (reader ["not-run"], out notRun);
						long.TryParse (reader ["inconclusive"], out inconclusive);
						long.TryParse (reader ["ignored"], out ignored);
						long.TryParse (reader ["skipped"], out skipped);
						long.TryParse (reader ["invalid"], out invalid);
					}
					if (reader.NodeType == XmlNodeType.Element && reader.Name == "test-suite" && (reader ["type"] == "TestFixture" || reader ["type"] == "TestCollection")) {
						var testCaseName = reader ["name"];
						writer.WriteLine (testCaseName);
						var time = reader.GetAttribute ("time") ?? "0"; // some nodes might not have the time :/
												// get the first node and then move in the siblings of the same type
						reader.ReadToDescendant ("test-case");
						do {
							if (reader.Name != "test-case")
								break;
							// read the test cases in the current node
							var status = reader ["result"];
							switch (status) {
							case "Success":
								writer.Write ("\t[PASS] ");
								break;
							case "Ignored":
								writer.Write ("\t[IGNORED] ");
								break;
							case "Error":
							case "Failure":
								writer.Write ("\t[FAIL] ");
								break;
							case "Inconclusive":
								writer.Write ("\t[INCONCLUSIVE] ");
								break;
							default:
								writer.Write ("\t[INFO] ");
								break;
							}
							writer.Write (reader ["name"]);
							if (status == "Failure" || status == "Error") { //  we need to print the message
								reader.ReadToDescendant ("message");
								writer.Write ($" : {reader.ReadElementContentAsString ()}");
								reader.ReadToNextSibling ("stack-trace");
								writer.Write ($" : {reader.ReadElementContentAsString ()}");
							}
							// add a new line
							writer.WriteLine ();
						} while (reader.ReadToNextSibling ("test-case"));
						writer.WriteLine ($"{testCaseName} {time} ms");
					}
				}
			}
			var passed = total - errors - failed - notRun - inconclusive - ignored - skipped - invalid;
			string resultLine = $"Tests run: {total} Passed: {passed} Inconclusive: {inconclusive} Failed: {failed + errors} Ignored: {ignored + skipped + invalid}";
			writer.WriteLine (resultLine);

			return (resultLine, total == 0 | errors != 0 || failed != 0);
		}

		static (string resultLine, bool failed) ParsexUnitXml (StreamReader stream, StreamWriter writer)
		{
			long total, errors, failed, notRun, inconclusive, ignored, skipped, invalid;
			total = errors = failed = notRun = inconclusive = ignored = skipped = invalid = 0L;
			using (var reader = XmlReader.Create (stream)) {
				while (reader.Read ()) {
					if (reader.NodeType == XmlNodeType.Element && reader.Name == "assembly") {
						long.TryParse (reader ["total"], out var assemblyCount);
						total += assemblyCount;
						long.TryParse (reader ["errors"], out var assemblyErrors);
						errors += assemblyErrors;
						long.TryParse (reader ["failed"], out var assemblyFailures);
						failed += assemblyFailures;
						long.TryParse (reader ["skipped"], out var assemblySkipped);
						skipped += assemblySkipped;
					}
					if (reader.NodeType == XmlNodeType.Element && reader.Name == "collection") {
						var testCaseName = reader ["name"].Replace ("Test collection for ", "");
						writer.WriteLine (testCaseName);
						var time = reader.GetAttribute ("time") ?? "0"; // some nodes might not have the time :/
												// get the first node and then move in the siblings of the same type
						reader.ReadToDescendant ("test");
						do {
							if (reader.Name != "test")
								break;
							// read the test cases in the current node
							var status = reader ["result"];
							switch (status) {
							case "Pass":
								writer.Write ("\t[PASS] ");
								break;
							case "Skip":
								writer.Write ("\t[IGNORED] ");
								break;
							case "Fail":
								writer.Write ("\t[FAIL] ");
								break;
							default:
								writer.Write ("\t[FAIL] ");
								break;
							}
							writer.Write (reader ["name"]);
							if (status == "Fail") { //  we need to print the message
								reader.ReadToDescendant ("message");
								writer.Write ($" : {reader.ReadElementContentAsString ()}");
								reader.ReadToNextSibling ("stack-trace");
								writer.Write ($" : {reader.ReadElementContentAsString ()}");
							}
							// add a new line
							writer.WriteLine ();
						} while (reader.ReadToNextSibling ("test"));
						writer.WriteLine ($"{testCaseName} {time} ms");
					}
				}
			}
			var passed = total - errors - failed - notRun - inconclusive - ignored - skipped - invalid;
			string resultLine = $"Tests run: {total} Passed: {passed} Inconclusive: {inconclusive} Failed: {failed + errors} Ignored: {ignored + skipped + invalid}";
			writer.WriteLine (resultLine);

			return (resultLine, total == 0 | errors != 0 || failed != 0);
		}

		public static string GetXmlFilePath (string path, Jargon xmlType)
		{
			var fileName = Path.GetFileName (path);
			switch (xmlType) {
			case Jargon.TouchUnit:
			case Jargon.NUnitV2:
				return path.Replace (fileName, $"nunit-{fileName}");
			case Jargon.xUnit:
				return path.Replace (fileName, $"xunit-{fileName}");
			default:
				return path;
			}
		}

		public static void CleanXml (string source, string destination)
		{
			using (var reader = new StreamReader (source))
			using (var writer = new StreamWriter (destination)) {
				string line;
				while ((line = reader.ReadLine ()) != null) {
					if (line.StartsWith ("ping", StringComparison.Ordinal) || line.Contains ("TouchUnitTestRun") || line.Contains ("NUnitOutput") || line.Contains ("<!--")) {
						continue;
					}
					if (line == "") // remove white lines, some files have them
						continue;
					if (line.Contains ("TouchUnitExtraData")) // always last node in TouchUnit
						break;
					writer.WriteLine (line);
				}
			}
		}

		public static (string resultLine, bool failed) GenerateHumanReadableResults (string source, string destination, Jargon xmlType)
		{
			(string resultLine, bool failed) parseData;
			using (var reader = new StreamReader (source)) 
			using (var writer = new StreamWriter (destination, true)) {
				switch (xmlType) {
				case Jargon.TouchUnit:
					parseData = ParseTouchUnitXml (reader, writer);
					break;
				case Jargon.NUnitV2:
					parseData = ParseNUnitXml (reader, writer);
					break;
				case Jargon.NUnitV3:
					parseData = ParseNUnitV3 (reader, writer);
					break;
				case Jargon.xUnit:
					parseData = ParsexUnitXml (reader, writer);
					break;
				default:
					parseData = ("", true);
					break;
				}
			}
			return parseData;
		}

		// get the file, parse it and add the attachments to the first node found
		public static void UpdateMissingData (string source, string destination, string applicationName, params (string path, string description) [] attachments)
		{
			// we could do this with a XmlReader and a Writer, but might be to complicated to get right, we pay with performance what we
			// cannot pay with brain cells.
			var doc = XDocument.Load (source);
			var attachmentsElement = new XElement ("attachments");
			foreach (var (path, description) in attachments) {
				attachmentsElement.Add (new XElement ("attachment",
					new XElement ("filePath", path),
					new XElement ("description", new XCData(description))));
			}

			// add the first test-suit and add the attachments
			var rooTestSuite = doc.Descendants ().Where (e => e.Name == "test-suite").FirstOrDefault ();
			rooTestSuite.Add (attachmentsElement);

			// get the test suites and make them all use the same app name for better parsing in VSTS
			var testSuitsElements = doc.Descendants ().Where (e => e.Name == "test-suite" && e.Attribute ("type")?.Value == "Assembly");
			if (!testSuitsElements.Any ())
				return;

			foreach (var suite in testSuitsElements) {
				suite.SetAttributeValue ("name", applicationName);
			}

			doc.Save (destination);
		}
	}
}