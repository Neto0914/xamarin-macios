# helpful rules to compile things for the various architectures

COMMON_I:= -I.
SIM32_I := $(COMMON_I)
SIM64_I := $(COMMON_I)
DEV7_I  := $(COMMON_I)
DEV7s_I := $(COMMON_I)
DEV64_I := $(COMMON_I)

SIMW_I  := $(COMMON_I)
DEVW_I  := $(COMMON_I)
DEVW64_32_I := $(COMMON_I)

SIM_TV_I:= $(COMMON_I)
DEV_TV_I:= $(COMMON_I)

define NativeCompilationTemplate

## ios simulator
.libs/iphonesimulator/%$(1).x86.o: %.m $(EXTRA_DEPENDENCIES) | .libs/iphonesimulator
	$$(call Q_2,OBJC,  [iphonesimulator]) $(SIMULATOR_CC) $(SIMULATOR86_OBJC_CFLAGS) $$(EXTRA_DEFINES) $(SIM32_I) -g $(2) -c $$< -o $$@

.libs/iphonesimulator/%$(1).x86.o: %.c $(EXTRA_DEPENDENCIES) | .libs/iphonesimulator
	$$(call Q_2,CC,    [iphonesimulator]) $(SIMULATOR_CC) $(SIMULATOR86_CFLAGS)      $$(EXTRA_DEFINES) $(SIM32_I) -g $(2) -c $$< -o $$@

.libs/iphonesimulator/%$(1).x86.o: %.s $(EXTRA_DEPENDENCIES) | .libs/iphonesimulator
	$$(call Q_2,ASM,   [iphonesimulator]) $(SIMULATOR_CC) $(SIMULATOR86_CFLAGS)      $$(EXTRA_DEFINES) $(SIM32_I) -g $(2) -c $$< -o $$@

.libs/iphonesimulator/%$(1).x86.dylib: | .libs/iphonesimulator
	$$(call Q_2,LD,    [iphonesimulator]) $(SIMULATOR_CC) $(SIMULATOR86_CFLAGS)      $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -L$(IOS_DESTDIR)$(XAMARIN_IOSSIMULATOR_SDK)/usr/lib -fapplication-extension

.libs/iphonesimulator/%$(1).x86.framework: | .libs/iphonesimulator
	$$(call Q_2,LD,    [iphonesimulator]) $(SIMULATOR_CC) $(SIMULATOR86_CFLAGS)      $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -F$(IOS_DESTDIR)$(XAMARIN_IOSSIMULATOR_SDK)/Frameworks -fapplication-extension

.libs/iphonesimulator/%$(1).x86_64.o: %.m $(EXTRA_DEPENDENCIES) | .libs/iphonesimulator
	$$(call Q_2,OBJC,  [iphonesimulator]) $(SIMULATOR_CC) $(SIMULATOR64_OBJC_CFLAGS) $$(EXTRA_DEFINES) $(SIM64_I) -g $(2) -c $$< -o $$@

.libs/iphonesimulator/%$(1).x86_64.o: %.c $(EXTRA_DEPENDENCIES) | .libs/iphonesimulator
	$$(call Q_2,CC,    [iphonesimulator]) $(SIMULATOR_CC) $(SIMULATOR64_CFLAGS)      $$(EXTRA_DEFINES) $(SIM64_I) -g $(2) -c $$< -o $$@

.libs/iphonesimulator/%$(1).x86_64.o: %.s $(EXTRA_DEPENDENCIES) | .libs/iphonesimulator
	$$(call Q_2,ASM,   [iphonesimulator]) $(SIMULATOR_CC) $(SIMULATOR64_CFLAGS)      $(SIM64_I) -g $(2) -c $$< -o $$@

.libs/iphonesimulator/%$(1).x86_64.dylib: | .libs/iphonesimulator
	$$(call Q_2,LD,    [iphonesimulator]) $(SIMULATOR_CC) $(SIMULATOR64_CFLAGS)      $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -L$(IOS_DESTDIR)$(XAMARIN_IOSSIMULATOR_SDK)/usr/lib -fapplication-extension

.libs/iphonesimulator/%$(1).x86_64.framework: | .libs/iphonesimulator
	$$(call Q_2,LD,    [iphonesimulator]) $(SIMULATOR_CC) $(SIMULATOR64_CFLAGS)      $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -F$(IOS_DESTDIR)$(XAMARIN_IOSSIMULATOR_SDK)/Frameworks -fapplication-extension

## ios device

.libs/iphoneos/%$(1).armv7.o: %.m $(EXTRA_DEPENDENCIES) | .libs/iphoneos
	$$(call Q_2,OBJC,  [iphoneos]) $(DEVICE_CC) $(DEVICE7_OBJC_CFLAGS)  $$(EXTRA_DEFINES) $(DEV7_I)  -g $(2) -c $$< -o $$@ 

.libs/iphoneos/%$(1).armv7.o: %.c $(EXTRA_DEPENDENCIES) | .libs/iphoneos
	$$(call Q_2,CC,    [iphoneos]) $(DEVICE_CC) $(DEVICE7_CFLAGS)       $$(EXTRA_DEFINES) $(DEV7_I)  -g $(2) -c $$< -o $$@ 

.libs/iphoneos/%$(1).armv7.dylib: | .libs/iphoneos
	$$(call Q_2,LD,    [iphoneos]) $(DEVICE_CC) $(DEVICE7_CFLAGS)       $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -L$(IOS_DESTDIR)$(XAMARIN_IPHONEOS_SDK)/usr/lib -fapplication-extension

.libs/iphoneos/%$(1).armv7.framework: | .libs/iphoneos
	$$(call Q_2,LD,    [iphoneos]) $(DEVICE_CC) $(DEVICE7_CFLAGS)       $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -F$(IOS_DESTDIR)$(XAMARIN_IPHONEOS_SDK)/Frameworks -fapplication-extension

.libs/iphoneos/%$(1).armv7s.o: %.m $(EXTRA_DEPENDENCIES) | .libs/iphoneos
	$$(call Q_2,OBJC,  [iphoneos]) $(DEVICE_CC) $(DEVICE7S_OBJC_CFLAGS) $$(EXTRA_DEFINES) $(DEV7s_I) -g $(2) -c $$< -o $$@ 

.libs/iphoneos/%$(1).armv7s.o: %.c $(EXTRA_DEPENDENCIES) | .libs/iphoneos
	$$(call Q_2,CC,    [iphoneos]) $(DEVICE_CC) $(DEVICE7S_CFLAGS)      $$(EXTRA_DEFINES) $(DEV7s_I) -g $(2) -c $$< -o $$@ 

.libs/iphoneos/%$(1).armv7s.dylib: | .libs/iphoneos
	$$(call Q_2,LD,    [iphoneos]) $(DEVICE_CC) $(DEVICE7S_CFLAGS)      $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -L$(IOS_DESTDIR)$(XAMARIN_IPHONEOS_SDK)/usr/lib -fapplication-extension

.libs/iphoneos/%$(1).armv7s.framework: | .libs/iphoneos
	$$(call Q_2,LD,    [iphoneos]) $(DEVICE_CC) $(DEVICE7S_CFLAGS)      $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -F$(IOS_DESTDIR)$(XAMARIN_IPHONEOS_SDK)/Frameworks -fapplication-extension

.libs/iphoneos/%$(1).arm64.o: %.m $(EXTRA_DEPENDENCIES) | .libs/iphoneos
	$$(call Q_2,OBJC,  [iphoneos]) $(DEVICE_CC) $(DEVICE64_OBJC_CFLAGS) $$(EXTRA_DEFINES) $(DEV64_I) -g $(2) -c $$< -o $$@ 

.libs/iphoneos/%$(1).arm64.o: %.c $(EXTRA_DEPENDENCIES) | .libs/iphoneos
	$$(call Q_2,CC,    [iphoneos]) $(DEVICE_CC) $(DEVICE64_CFLAGS)      $$(EXTRA_DEFINES) $(DEV64_I) -g $(2) -c $$< -o $$@ 

.libs/iphoneos/%$(1).arm64.o: %.s $(EXTRA_DEPENDENCIES) | .libs/iphoneos
	$$(call Q_2,ASM,   [iphoneos]) $(DEVICE_CC) $(DEVICE64_CFLAGS)      $$(EXTRA_DEFINES) $(DEV64_I) -g $(2) -c $$< -o $$@

.libs/iphoneos/%$(1).arm64.dylib: | .libs/iphoneos
	$$(call Q_2,LD,    [iphoneos]) $(DEVICE_CC) $(DEVICE64_CFLAGS)      $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -L$(IOS_DESTDIR)$(XAMARIN_IPHONEOS_SDK)/usr/lib -fapplication-extension

.libs/iphoneos/%$(1).arm64.framework: | .libs/iphoneos
	$$(call Q_2,LD,    [iphoneos]) $(DEVICE_CC) $(DEVICE64_CFLAGS)      $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -F$(IOS_DESTDIR)$(XAMARIN_IPHONEOS_SDK)/Frameworks -fapplication-extension  -miphoneos-version-min=8.0

## watch simulator

.libs/watchsimulator/%$(1).x86.o: %.m $(EXTRA_DEPENDENCIES) | .libs/watchsimulator
	$$(call Q_2,OBJC,  [watchsimulator]) $(SIMULATOR_CC) $(SIMULATORWATCH_OBJC_CFLAGS) $$(EXTRA_DEFINES) $(SIMW_I) -g $(2) -c $$< -o $$@

.libs/watchsimulator/%$(1).x86.o: %.c $(EXTRA_DEPENDENCIES) | .libs/watchsimulator
	$$(call Q_2,CC,    [watchsimulator]) $(SIMULATOR_CC) $(SIMULATORWATCH_CFLAGS)      $$(EXTRA_DEFINES) $(SIMW_I) -g $(2) -c $$< -o $$@

.libs/watchsimulator/%$(1).x86.o: %.s $(EXTRA_DEPENDENCIES) | .libs/watchsimulator
	$$(call Q_2,ASM,   [watchsimulator]) $(SIMULATOR_CC) $(SIMULATORWATCH_CFLAGS)      $$(EXTRA_DEFINES) $(SIMW_I) -g $(2) -c $$< -o $$@

.libs/watchsimulator/%$(1).x86.dylib: | .libs/watchsimulator
	$$(call Q_2,LD,    [watchsimulator]) $(SIMULATOR_CC) $(SIMULATORWATCH_CFLAGS)      $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -L$(IOS_DESTDIR)$(XAMARIN_WATCHSIMULATOR_SDK)/usr/lib -fapplication-extension

.libs/watchsimulator/%$(1).x86.framework: | .libs/watchsimulator
	$$(call Q_2,LD,    [watchsimulator]) $(SIMULATOR_CC) $(SIMULATORWATCH_CFLAGS)      $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -F$(IOS_DESTDIR)$(XAMARIN_WATCHSIMULATOR_SDK)/Frameworks -fapplication-extension

## watch device

.libs/watchos/%$(1).armv7k.o: %.m $(EXTRA_DEPENDENCIES) | .libs/watchos
	$$(call Q_2,OBJC,  [watchos]) $(DEVICE_CC) $(DEVICEWATCH_OBJC_CFLAGS)    $$(EXTRA_DEFINES) $(DEVW_I) -g $(2) -c $$< -o $$@ 

.libs/watchos/%$(1).armv7k.o: %.c $(EXTRA_DEPENDENCIES) | .libs/watchos
	$$(call Q_2,CC,    [watchos]) $(DEVICE_CC) $(DEVICEWATCH_CFLAGS)         $$(EXTRA_DEFINES) $(DEVW_I) -g $(2) -c $$< -o $$@ 

.libs/watchos/%$(1).armv7k.dylib: | .libs/watchos
	$$(call Q_2,LD,    [watchos]) $(DEVICE_CC) $(DEVICEWATCH_CFLAGS)          $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -L$(IOS_DESTDIR)$(XAMARIN_WATCHOS_SDK)/usr/lib -fapplication-extension

.libs/watchos/%$(1).armv7k.framework: | .libs/watchos
	$$(call Q_2,LD,    [watchos]) $(DEVICE_CC) $(DEVICEWATCH_CFLAGS)          $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -F$(IOS_DESTDIR)$(XAMARIN_WATCHOS_SDK)/Frameworks -fapplication-extension

.libs/watchos/%$(1).arm64_32.o: %.m $(EXTRA_DEPENDENCIES) | .libs/watchos
	$$(call Q_2,OBJC,  [watchos]) $(DEVICE_CC) $(DEVICEWATCH64_32_OBJC_CFLAGS)    $$(EXTRA_DEFINES) $(DEVW64_32_I) -g $(2) -c $$< -o $$@

.libs/watchos/%$(1).arm64_32.o: %.c $(EXTRA_DEPENDENCIES) | .libs/watchos
	$$(call Q_2,CC,    [watchos]) $(DEVICE_CC) $(DEVICEWATCH64_32_CFLAGS)         $$(EXTRA_DEFINES) $(DEVW64_32_I) -g $(2) -c $$< -o $$@

.libs/watchos/%$(1).arm64_32.dylib: | .libs/watchos
	$$(call Q_2,LD,    [watchos]) $(DEVICE_CC) $(DEVICEWATCH64_32_CFLAGS)          $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -L$(IOS_DESTDIR)$(XAMARIN_WATCHOS_SDK)/usr/lib -fapplication-extension

.libs/watchos/%$(1).arm64_32.framework: | .libs/watchos
	$$(call Q_2,LD,    [watchos]) $(DEVICE_CC) $(DEVICEWATCH64_32_CFLAGS)          $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -F$(IOS_DESTDIR)$(XAMARIN_WATCHOS_SDK)/Frameworks -fapplication-extension

## tv simulator

.libs/tvsimulator/%$(1).x86_64.o: %.m $(EXTRA_DEPENDENCIES) | .libs/tvsimulator
	$$(call Q_2,OBJC,  [tvsimulator]) $(SIMULATOR_CC) $(SIMULATORTV_OBJC_CFLAGS)    $$(EXTRA_DEFINES) $(SIM_TV_I) -g $(2) -c $$< -o $$@

.libs/tvsimulator/%$(1).x86_64.o: %.c $(EXTRA_DEPENDENCIES) | .libs/tvsimulator
	$$(call Q_2,CC,    [tvsimulator]) $(SIMULATOR_CC) $(SIMULATORTV_CFLAGS)         $$(EXTRA_DEFINES) $(SIM_TV_I) -g $(2) -c $$< -o $$@

.libs/tvsimulator/%$(1).x86_64.o: %.s $(EXTRA_DEPENDENCIES) | .libs/tvsimulator
	$$(call Q_2,ASM,   [tvsimulator]) $(SIMULATOR_CC) $(SIMULATORTV_CFLAGS)         $$(EXTRA_DEFINES) $(SIM_TV_I) -g $(2) -c $$< -o $$@

.libs/tvsimulator/%$(1).x86_64.dylib: | .libs/tvsimulator
	$$(call Q_2,LD,    [tvsimulator]) $(SIMULATOR_CC) $(SIMULATORTV_CFLAGS)         $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -L$(IOS_DESTDIR)$(XAMARIN_TVSIMULATOR_SDK)/usr/lib -fapplication-extension

.libs/tvsimulator/%$(1).x86_64.framework: | .libs/tvsimulator
	$$(call Q_2,LD,    [tvsimulator]) $(SIMULATOR_CC) $(SIMULATORTV_CFLAGS)         $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -F$(IOS_DESTDIR)$(XAMARIN_TVSIMULATOR_SDK)/Frameworks -fapplication-extension

## tv device

.libs/tvos/%$(1).arm64.o: %.m $(EXTRA_DEPENDENCIES) | .libs/tvos
	$$(call Q_2,OBJC,  [tvos]) $(DEVICE_CC)       $(DEVICETV_OBJC_CFLAGS)       $$(EXTRA_DEFINES) $(DEV_TV_I) -g $(2) -c $$< -o $$@ 

.libs/tvos/%$(1).arm64.o: %.c $(EXTRA_DEPENDENCIES) | .libs/tvos
	$$(call Q_2,CC,    [tvos]) $(DEVICE_CC)    $(DEVICETV_CFLAGS)            $$(EXTRA_DEFINES) $(DEV_TV_I) -g $(2) -c $$< -o $$@ 

.libs/tvos/%$(1).arm64.o: %.s $(EXTRA_DEPENDENCIES) | .libs/tvos
	$$(call Q_2,ASM,   [tvos]) $(DEVICE_CC)    $(DEVICETV_CFLAGS)            $$(EXTRA_DEFINES) $(DEV_TV_I) -g $(2) -c $$< -o $$@

.libs/tvos/%$(1).arm64.dylib: | .libs/tvos
	$$(call Q_2,LD,    [tvos]) $(DEVICE_CC)    $(DEVICETV_CFLAGS)            $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -L$(IOS_DESTDIR)$(XAMARIN_TVOS_SDK)/usr/lib -fapplication-extension

.libs/tvos/%$(1).arm64.framework: | .libs/tvos
	$$(call Q_2,LD,    [tvos]) $(DEVICE_CC)    $(DEVICETV_CFLAGS)            $$(EXTRA_FLAGS) -dynamiclib -o $$@ $$^ -F$(IOS_DESTDIR)$(XAMARIN_TVOS_SDK)/Frameworks -fapplication-extension
endef

$(eval $(call NativeCompilationTemplate,,-O2))
$(eval $(call NativeCompilationTemplate,-debug,-DDEBUG))

.libs/iphoneos .libs/iphonesimulator .libs/watchos .libs/watchsimulator .libs/tvos .libs/tvsimulator .libs/iosmac:
	$(Q) mkdir -p $@

%.csproj.inc: %.csproj $(TOP)/Make.config $(TOP)/mk/mono.mk $(TOP)/tools/common/create-makefile-fragment.sh
	$(Q) $(TOP)/tools/common/create-makefile-fragment.sh $(abspath $<) $(abspath $@)
