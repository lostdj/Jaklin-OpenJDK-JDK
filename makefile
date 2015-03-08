avnp ?= ./../../myavn
override avnp := $(shell realpath -m $(avnp))

libmkf ?= $(avnp)/lib.mk
include $(libmkf)

buildp := $(mf_buildp)/jdk
$(eval $(call mf_mkout))
$(eval $(shell mkdir -p $(buildp)))

include $(avnp)/avnmko.mk

my := $(mf_rootp)/my
myemb := $(my)/emb

jdkmkp := $(mf_rootp)/make
jdkmkdatap := $(jdkmkp)/data
jdkmkscriptsp := $(jdkmkp)/scripts
btoolsp := $(jdkmkp)/src
btoolssrcp := $(btoolsp)/classes
nbtoolssrcp := $(btoolsp)/native/genconstants

srcp := $(mf_rootp)/src
jbasep := $(srcp)/java.base
jloggingp := $(srcp)/java.logging
jmanagementp := $(srcp)/java.management
jlocaledatap := $(srcp)/jdk.localedata
jjdkruntimep := $(srcp)/jdk.runtime
jdesktopp := $(srcp)/java.desktop
jxmlp := ../myjdkjaxp/src/java.xml

gensrcp := $(buildp)/gensrc
gensrchp := $(buildp)/gensrc_headers
modulesp := $(buildp)/modules
jbasebp := $(modulesp)/java.base
jbasegensrcp := $(gensrcp)/java.base
jbasegensrchp := $(gensrchp)/java.base
jlocaledatabp := $(modulesp)/jdk.localedata
jlocaledatagensrcp := $(gensrcp)/jdk.localedata
jstandardcharsetsgensrcp := $(gensrcp)/standardcharsets
jthincompatbp := $(modulesp)/thincompat
jembbp := $(modulesp)/emb

lib := $(buildp)/lib

OPENJDK_TARGET_OS :=
ifeq ($(mf_target_tux),t)
	OPENJDK_TARGET_OS :=linux
else ifeq ($(mf_target_osx),t)
	OPENJDK_TARGET_OS :=macosx
else ifeq ($(mf_target_win),t)
	OPENJDK_TARGET_OS :=windows
else ifeq ($(mf_target_ems),t)
	OPENJDK_TARGET_OS :=linux
endif

OPENJDK_TARGET_OS_API_DIR :=
ifneq ($(mf_target_tux)$(mf_target_osx)$(mf_target_ems),)
	OPENJDK_TARGET_OS_API_DIR :=unix
else ifeq ($(mf_target_win),t)
	OPENJDK_TARGET_OS_API_DIR :=windows
endif

include $(mf_rootp)/ListPathsSafely.mk

define CacheFind
  $(shell find $1 \( -type f -o -type l \) $2)
endef

$(eval jretrolambda = $(call avnmkfdbprint,jretrolambda))

t_b2h_outo := $(call avnmkfdbprint,t_b2h_outo)
$(eval t_b2h_run_raw = $(call avnmkfdbprint,t_b2h_run_raw))
$(eval t_b2h_run = $(call avnmkfdbprint,t_b2h_run))

t_nama_flags := $(call avnmkfdbprint,t_nama_flags)
t_nama_outo := $(call avnmkfdbprint,t_nama_outo)
$(eval t_nama_run = $(call avnmkfdbprint,t_nama_run))

#----------------------------------------


t_btools_outp := $(buildp)/btools
t_btools_dep := $(t_btools_outp)/dep_
t_btools_java := $(mf_java) -XX:+UseSerialGC -Xms32M -Xmx512M -cp $(t_btools_outp)
TOOL_GENERATECHARACTER := $(t_btools_java) build.tools.generatecharacter.GenerateCharacter
TOOL_CHARSETMAPPING := $(t_btools_java) build.tools.charsetmapping.Main
TOOL_HASHER := $(t_btools_java) build.tools.hasher.Hasher
TOOL_SPP := $(t_btools_java) build.tools.spp.Spp
TOOL_COMPILEPROPERTIES := $(t_btools_java) build.tools.compileproperties.CompileProperties
TOOL_CHARACTERNAME := $(t_btools_java) build.tools.generatecharacter.CharacterName
TOOL_GENERATECURRENCYDATA := $(t_btools_java) build.tools.generatecurrencydata.GenerateCurrencyData
TOOL_MAKEJAVASECURITY := $(t_btools_java) build.tools.makejavasecurity.MakeJavaSecurity
TOOL_GENERATEBREAKITERATORDATA := build.tools.generatebreakiteratordata.GenerateBreakIteratorData
TOOL_TZDB := $(t_btools_java) build.tools.tzdb.TzdbZoneRulesCompiler
TOOL_BLACKLISTED_CERTS := $(t_btools_java) build.tools.blacklistedcertsconverter.BlacklistedCertsConverter

t_btools_javac := $(mf_default_javac)

t_btools_src := $(shell find $(btoolssrcp) -name '*.java')

t_btools_objs := $(call mf_javaobjs,$(t_btools_src),$(btoolssrcp),$(t_btools_outp))

$(t_btools_objs): $(t_btools_outp)/%.class: ;

$(t_btools_dep): $(t_btools_src) $(t_btools_objs)
	@mkdir -p $(t_btools_outp)
	$(t_btools_javac) -source 8 -target 8 -Xlint:all,-deprecation,-unchecked,-rawtypes,-cast,-serial,-dep-ann,-static,-fallthrough,-try,-varargs,-empty,-finally -implicit:none -bootclasspath $(mf_java_rtjar) -cp "$(JAVA_HOME)/lib/tools.jar" -sourcepath $(btoolssrcp) -d $(t_btools_outp) $(t_btools_src)
	@touch $(@)

$(eval $(call mf_echot,btools,"Building t_btools..."))

.PHONY: t_btools
t_btools: | $(call mf_echot_dep,btools) $(t_btools_dep) \
	;


#----------------------------------------


t_nbtools_outp := $(buildp)/nbtools
t_nbtools_outch := $(t_nbtools_outp)/genSocketOptionRegistry
t_nbtools_outch_j := $(jbasegensrcp)/sun/nio/ch/SocketOptionRegistry.java
ifeq ($(mf_target_win),)
	t_nbtools_outfs := $(t_nbtools_outp)/genUnixConstants
	t_nbtools_outfs_j := $(jbasegensrcp)/sun/nio/fs/UnixConstants.java
endif

t_nbtools_cc := $(mf_cxx_gcc)
t_nbtools_cc_flags := $(mf_cxx_gcc_flags) -D_ALLBSD_SOURCE

t_nbtools_src_ch := $(nbtoolssrcp)/ch/genSocketOptionRegistry.c
ifeq ($(mf_target_win),)
	t_nbtools_src_fs := $(nbtoolssrcp)/fs/genUnixConstants.c
endif

$(t_nbtools_outch): $(t_nbtools_src_ch)
	@mkdir -p $(t_nbtools_outp)
	$(call mf_linkobj,$(t_nbtools_cc),$(t_nbtools_cc_flags))

$(t_nbtools_outch_j): $(t_nbtools_outch)
	@echo "Generating $(@)..."
	@mkdir -p $(@D)
	rm -f $(@).tmp
	rm -f $(@)
	$(<) > $(@).tmp
	mv $(@).tmp $(@)

ifeq ($(mf_target_win),)
$(t_nbtools_outfs): $(t_nbtools_src_fs)
	@mkdir -p $(t_nbtools_outp)
	$(call mf_linkobj,$(t_nbtools_cc),$(t_nbtools_cc_flags))

$(t_nbtools_outfs_j): $(t_nbtools_outfs)
	@echo "Generating $(@)..."
	@mkdir -p $(@D)
	rm -f $(@).tmp
	rm -f $(@)
	$(<) > $(@).tmp
	mv $(@).tmp $(@)
endif

$(eval $(call mf_echot,nbtools,"Building t_nbtools..."))

.PHONY: t_nbtools
t_nbtools: | $(call mf_echot_dep,nbtools) $(t_nbtools_outch_j) $(if $(mf_target_win),,$(t_nbtools_outfs_j)) \
	;


#----------------------------------------


t_glocaled_localfiles := $(shell find $(jbasep)/share/classes \
	$(jlocaledatap)/share/classes \
	-name "FormatData_*.java" -o -name "FormatData_*.properties" -o \
	-name "CollationData_*.java" -o -name "CollationData_*.properties" -o \
	-name "TimeZoneNames_*.java" -o -name "TimeZoneNames_*.properties" -o \
	-name "LocaleNames_*.java" -o -name "LocaleNames_*.properties" -o \
	-name "CurrencyNames_*.java" -o -name "CurrencyNames_*.properties" -o \
	-name "CalendarData_*.java" -o -name "CalendarData_*.properties" -o \
	-name "BreakIteratorInfo_*.java" -o -name "BreakIteratorRules_*.java")

t_glocaled_resources := $(sort $(subst .properties,,$(subst .java,,$(notdir $(t_glocaled_localfiles)))))

t_glocaled_enlocales := en%

t_glocaled_nonenlocales := ja-JP-JP nb-NO nn-NO th-TH-TH

t_glocaled_sed_enargs := -e 's|$(hash)warn This file is preprocessed before being compiled|// -- This file was mechanically generated: Do not edit! -- //|g'
t_glocaled_sed_nonenargs := $(t_glocaled_sed_enargs)

t_glocaled_sed_enargs += -e 's/$(hash)Lang$(hash)/En/' \
    -e 's/$(hash)Package$(hash)/sun.util.locale.provider/'
t_glocaled_sed_nonenargs += -e 's/$(hash)Lang$(hash)/NonEn/' \
    -e 's/$(hash)Package$(hash)/sun.util.resources.provider/'

# This macro creates a sed expression that substitues for example:
# #FormatData_ENLocales# with: en% locales.
define t_glocaled_capturelocale
  $1_LOCALES := $$(subst _,-,$$(filter-out $1, $$(subst $1_,,$$(filter $1_%, $(t_glocaled_resources)))))
  $1_EN_LOCALES := $$(filter $(t_glocaled_enlocales), $$($1_LOCALES))
  $1_NON_EN_LOCALES := $$(filter-out $(t_glocaled_enlocales), $$($1_LOCALES))

  # Special handling for Chinese locales to include implicit scripts
  $1_NON_EN_LOCALES := $$(subst zh-CN,zh-CN$$(space)zh-Hans-CN, $$($1_NON_EN_LOCALES))
  $1_NON_EN_LOCALES := $$(subst zh-SG,zh-SG$$(space)zh-Hans-SG, $$($1_NON_EN_LOCALES))
  $1_NON_EN_LOCALES := $$(subst zh-HK,zh-HK$$(space)zh-Hant-HK, $$($1_NON_EN_LOCALES))
  $1_NON_EN_LOCALES := $$(subst zh-MO,zh-MO$$(space)zh-Hant-MO, $$($1_NON_EN_LOCALES))
  $1_NON_EN_LOCALES := $$(subst zh-TW,zh-TW$$(space)zh-Hant-TW, $$($1_NON_EN_LOCALES))

  # TODO: Should it be t_glocaled_enlocales?
  ALL_EN_LOCALES += $$($1_EN_LOCALES)
  t_glocaled_nonenlocales += $$($1_NON_EN_LOCALES)

  # Don't sed in a space if there are no locales.
  t_glocaled_sed_enargs += -e 's/$$(hash)$1_Locales$$(hash)/$$(if $$($1_EN_LOCALES),$$(space)$$($1_EN_LOCALES),)/g'
  t_glocaled_sed_nonenargs += -e 's/$$(hash)$1_Locales$$(hash)/$$(if $$($1_NON_EN_LOCALES),$$(space)$$($1_NON_EN_LOCALES),)/g'
endef

#sun.text.resources.FormatData
$(eval $(call t_glocaled_capturelocale,FormatData))

#sun.text.resources.CollationData
$(eval $(call t_glocaled_capturelocale,CollationData))

#sun.text.resources.BreakIteratorInfo
$(eval $(call t_glocaled_capturelocale,BreakIteratorInfo))

#sun.text.resources.BreakIteratorRules
$(eval $(call t_glocaled_capturelocale,BreakIteratorRules))

#sun.util.resources.TimeZoneNames
$(eval $(call t_glocaled_capturelocale,TimeZoneNames))

#sun.util.resources.LocaleNames
$(eval $(call t_glocaled_capturelocale,LocaleNames))

#sun.util.resources.CurrencyNames
$(eval $(call t_glocaled_capturelocale,CurrencyNames))

#sun.util.resources.CalendarData
$(eval $(call t_glocaled_capturelocale,CalendarData))

t_glocaled_sed_enargs += -e 's/$(hash)AvailableLocales_Locales$(hash)/$(sort $(ALL_EN_LOCALES))/g'
t_glocaled_sed_nonenargs += -e 's/$(hash)AvailableLocales_Locales$(hash)/$(sort $(t_glocaled_nonenlocales))/g'

t_glocaled_baselocaledata := $(jbasegensrcp)/sun/util/locale/provider/EnLocaleDataMetaInfo.java
t_glocaled_localedata := $(jlocaledatagensrcp)/sun/util/resources/provider/NonEnLocaleDataMetaInfo.java
t_glocaled_crbc_dst := $(jbasegensrcp)/sun/util/CoreResourceBundleControl.java
t_glocaled_crbc_cmd := $(jdkmkscriptsp)/localelist.sh

t_glocaled_jre_nonexist_locales := en en_US de_DE es_ES fr_FR it_IT ja_JP ko_KR sv_SE zh

LocaleDataMetaInfoTmpl := $(jbasep)/share/classes/sun/util/locale/provider/LocaleDataMetaInfo-XLocales.java.template
CoreResourceBundleControlTmpl := $(jbasep)/share/classes/sun/util/CoreResourceBundleControl-XLocales.java.template

$(t_glocaled_baselocaledata): $(LocaleDataMetaInfoTmpl)
	@mkdir -p $(@D)
	@echo Generating sun/util/locale/provider/EnLocaleDataMetaInfo.java from $(words $(t_glocaled_resources)) found resources.
	sed $(t_glocaled_sed_enargs) $< > $@

$(t_glocaled_localedata): $(LocaleDataMetaInfoTmpl)
	@mkdir -p $(@D)
	@echo Generating sun/util/resources/provider/NonEnLocaleDataMetaInfo.java from $(words $(t_glocaled_resources)) found resources.
	sed $(t_glocaled_sed_nonenargs) $< > $@

$(t_glocaled_crbc_dst): $(CoreResourceBundleControlTmpl) $(t_glocaled_crbc_cmd)
	@mkdir -p $(@D)
	NAWK="awk" SED="sed" sh $(t_glocaled_crbc_cmd) "$(t_glocaled_jre_nonexist_locales)" $< $@

$(eval $(call mf_echot,glocaled,"Building t_glocaled..."))

.PHONY: t_glocaled
t_glocaled: | $(call mf_echot_dep,glocaled) $(t_glocaled_baselocaledata) $(t_glocaled_localedata) $(t_glocaled_crbc_dst) \
	;


#----------------------------------------


GENSRC_CHARACTERDATA :=

CHARACTERDATA := $(jdkmkdatap)/characterdata
UNICODEDATA := $(jdkmkdatap)/unicodedata

define SetupCharacterData
  $(jbasegensrcp)/java/lang/$1.java: $(CHARACTERDATA)/$1.java.template $(BUILD_TOOLS_JDK)
	@mkdir -p $$(@D)
	@echo Generating $1.java...
	$(TOOL_GENERATECHARACTER) $2 \
	    -template $(CHARACTERDATA)/$1.java.template \
	    -spec $(UNICODEDATA)/UnicodeData.txt \
	    -specialcasing $(UNICODEDATA)/SpecialCasing.txt \
	    -proplist $(UNICODEDATA)/PropList.txt \
	    -o $(jbasegensrcp)/java/lang/$1.java -string \
	    -usecharforbyte $3

  GENSRC_CHARACTERDATA += $(jbasegensrcp)/java/lang/$1.java
endef

$(eval $(call SetupCharacterData,CharacterDataLatin1, , -latin1 8))
$(eval $(call SetupCharacterData,CharacterData00, -plane 0, 11 4 1))
$(eval $(call SetupCharacterData,CharacterData01, -plane 1, 11 4 1))
$(eval $(call SetupCharacterData,CharacterData02, -plane 2, 11 4 1))
$(eval $(call SetupCharacterData,CharacterData0E, -plane 14, 11 4 1))

# Copy two Java files that need no preprocessing.
$(jbasegensrcp)/java/lang/%.java: $(CHARACTERDATA)/%.java.template
	@echo Generating $(@F)...
	cp $(<) $(@)

GENSRC_CHARACTERDATA += \
	$(jbasegensrcp)/java/lang/CharacterDataUndefined.java \
	$(jbasegensrcp)/java/lang/CharacterDataPrivateUse.java

$(GENSRC_CHARACTERDATA): $(t_btools)

$(eval $(call mf_echot,gchard,"Building t_gchard..."))

.PHONY: t_gchard
t_gchard: | $(call mf_echot_dep,gchard) $(t_btools) $(GENSRC_CHARACTERDATA) \
	;


#----------------------------------------


$(jbasegensrcp)/sun/misc/Version.java: $(jbasep)/share/classes/sun/misc/Version.java.template
	@mkdir -p $(@D)
	rm -f $@
	rm -f $@.tmp
	@echo Generating sun/misc/Version.java
	sed -e 's/@@launcher_name@@/myavn/g' \
	    -e 's/@@java_version@@/1.9.0/g' \
	    -e 's/@@java_runtime_version@@/1.9.0-'$$(date +%y.%m.%d_%H.%M.%S)'/g' \
	    -e 's/@@java_runtime_name@@/myavn/g' \
	    -e 's/@@java_profile_name@@//g' \
	    $< > $@.tmp
	@mv $@.tmp $@

$(eval $(call mf_echot,gversion,"Building t_gversion..."))

.PHONY: t_gversion
t_gversion: | $(call mf_echot_dep,gversion) $(jbasegensrcp)/sun/misc/Version.java \
	;


#----------------------------------------


CHARSET_DATA_DIR := $(jdkmkdatap)/charsetmapping
CHARSET_GENSRC_JAVA_DIR_BASE := $(jbasegensrcp)/sun/nio/cs
CHARSET_DONE_BASE := $(CHARSET_GENSRC_JAVA_DIR_BASE)/_the.charsetmapping
CHARSET_TEMPLATES := \
    $(CHARSET_DATA_DIR)/SingleByte-X.java.template \
    $(CHARSET_DATA_DIR)/DoubleByte-X.java.template

$(CHARSET_DONE_BASE)-sbcs: $(CHARSET_DATA_DIR)/sbcs $(CHARSET_TEMPLATES)
	@mkdir -p $(@D)
	$(TOOL_CHARSETMAPPING) $(CHARSET_DATA_DIR) $(CHARSET_GENSRC_JAVA_DIR_BASE) sbcs
	touch '$@'

CHARSET_STANDARD_GENSRC_DIR := $(jstandardcharsetsgensrcp)
CHARSET_STANDARD_DATA := $(CHARSET_DATA_DIR)/standard-charsets
CHARSET_STANDARD_JAVA := sun/nio/cs/StandardCharsets.java
CHARSET_STANDARD_JAVA_TMPL := $(jbasep)/share/classes/$(CHARSET_STANDARD_JAVA).template
CHARSET_STANDARD_JAVA_OUT := $(jbasegensrcp)/$(CHARSET_STANDARD_JAVA)

CHARSET_ALIASES_TABLES_AWK := ' \
    BEGIN { n = 1; m = 1; } \
    /^[ \t]*charset / { \
      csn = $$2; cln = $$3; \
      lcsn = tolower(csn); \
      lcsns[n++] = lcsn; \
      csns[lcsn] = csn; \
      classMap[lcsn] = cln; \
      if (n > 2) \
        printf "    };\n\n"; \
      printf "    static final String[] aliases_%s = new String[] {\n", cln; \
    } \
    /^[ \t]*alias / { \
      acsns[m++] = tolower($$2); \
      aliasMap[tolower($$2)] = lcsn; \
      printf "        \"%s\",\n", $$2; \
    } \
    END { \
      printf "    };\n\n"; \
    } '

CHARSET_ALIASES_MAP_AWK := ' \
    /^[ \t]*charset / { \
      csn = $$2; \
      lcsn = tolower(csn); \
    } \
    /^[ \t]*alias / { \
      an = tolower($$2); \
      printf "%-20s \"%s\"\n", an, lcsn; \
    } '

CHARSET_CLASSES_MAP_AWK := ' \
    /^[ \t]*charset / { \
      csn = $$2; cln = $$3; \
      lcsn = tolower(csn); \
      printf "%-20s \"%s\"\n", lcsn, cln; \
    } '

# This target should be referenced using the order-only operator (|)
$(CHARSET_STANDARD_GENSRC_DIR):
	@mkdir -p '$@'

$(CHARSET_STANDARD_GENSRC_DIR)/aliases-tables.java.snippet: $(CHARSET_STANDARD_DATA) \
    | $(CHARSET_STANDARD_GENSRC_DIR)
	awk < '$<' > '$@' $(CHARSET_ALIASES_TABLES_AWK)

$(CHARSET_STANDARD_GENSRC_DIR)/aliases-map: $(CHARSET_STANDARD_DATA) \
    | $(CHARSET_STANDARD_GENSRC_DIR)
	awk < '$<' > '$@' $(CHARSET_ALIASES_MAP_AWK)

$(CHARSET_STANDARD_GENSRC_DIR)/classes-map: $(CHARSET_STANDARD_DATA) \
    | $(CHARSET_STANDARD_GENSRC_DIR)
	awk < '$<' > '$@' $(CHARSET_CLASSES_MAP_AWK)

$(CHARSET_STANDARD_GENSRC_DIR)/aliases-map.java.snippet: $(CHARSET_STANDARD_GENSRC_DIR)/aliases-map \
    | $(CHARSET_STANDARD_GENSRC_DIR)
	$(TOOL_HASHER) -i Aliases < '$<' > '$@'

$(CHARSET_STANDARD_GENSRC_DIR)/classes-map.java.snippet: $(CHARSET_STANDARD_GENSRC_DIR)/classes-map \
    | $(CHARSET_STANDARD_GENSRC_DIR)
	$(TOOL_HASHER) -i Classes < '$<' > '$@'

$(CHARSET_STANDARD_GENSRC_DIR)/cache-map.java.snippet: $(CHARSET_STANDARD_GENSRC_DIR)/classes-map \
    | $(CHARSET_STANDARD_GENSRC_DIR)
	$(TOOL_HASHER) -i -e Cache -t Charset < '$<' > '$@'

# Processing of template depends on the snippets being generated first
$(CHARSET_STANDARD_JAVA_OUT): \
    $(CHARSET_STANDARD_GENSRC_DIR)/aliases-tables.java.snippet \
    $(CHARSET_STANDARD_GENSRC_DIR)/aliases-map.java.snippet \
    $(CHARSET_STANDARD_GENSRC_DIR)/classes-map.java.snippet \
    $(CHARSET_STANDARD_GENSRC_DIR)/cache-map.java.snippet
	@mkdir -p $(@D)
	rm -f $(@) $(@).includes.tmp $(@).replacements.tmp
	gawk 'function matches(pattern) { return ($$0 ~ "^[ \t]*" pattern "[ \t]*$$") } function include(filename) { while ((getline < filename) == 1) print ; close(filename) } { if (matches("_INCLUDE_ALIASES_TABLES_")) { include("$(CHARSET_STANDARD_GENSRC_DIR)/aliases-tables.java.snippet") } else if (matches("_INCLUDE_ALIASES_MAP_")) { include("$(CHARSET_STANDARD_GENSRC_DIR)/aliases-map.java.snippet") } else if (matches("_INCLUDE_CLASSES_MAP_")) { include("$(CHARSET_STANDARD_GENSRC_DIR)/classes-map.java.snippet") } else if (matches("_INCLUDE_CACHE_MAP_")) { include("$(CHARSET_STANDARD_GENSRC_DIR)/cache-map.java.snippet") } else print }' < $(CHARSET_STANDARD_JAVA_TMPL) > $(@).includes.tmp
	cat < $(@).includes.tmp > $(@).replacements.tmp
	rm -f $(@).includes.tmp
	mv $(@).replacements.tmp $(@)

$(eval $(call mf_echot,gcharmap,"Building t_gcharmap..."))

.PHONY: t_gcharmap
t_gcharmap: | $(call mf_echot_dep,gcharmap) $(t_btools) $(CHARSET_DONE_BASE)-sbcs $(CHARSET_STANDARD_JAVA_OUT) \
	;


#----------------------------------------


GENSRC_CHARSETCODER :=

GENSRC_CHARSETCODER_DST := $(jbasegensrcp)/java/nio/charset

GENSRC_CHARSETCODER_SRC := $(jbasep)/share/classes/java/nio

GENSRC_CHARSETCODER_TEMPLATE := $(GENSRC_CHARSETCODER_SRC)/charset/Charset-X-Coder.java.template

$(GENSRC_CHARSETCODER_DST)/CharsetDecoder.java: $(GENSRC_CHARSETCODER_TEMPLATE)
	@mkdir -p $(@D)
	rm -f $@.tmp
	$(TOOL_SPP) < $< >$@.tmp \
	    -Kdecoder \
	    -DA='A' \
	    -Da='a' \
	    -DCode='Decode' \
	    -Dcode='decode' \
	    -DitypesPhrase='bytes in a specific charset' \
	    -DotypesPhrase='sixteen-bit Unicode characters' \
	    -Ditype='byte' \
	    -Dotype='character' \
	    -DItype='Byte' \
	    -DOtype='Char' \
	    -Dcoder='decoder' \
	    -DCoder='Decoder' \
	    -Dcoding='decoding' \
	    -DOtherCoder='Encoder' \
	    -DreplTypeName='string' \
	    -DdefaultRepl='"\\uFFFD"' \
	    -DdefaultReplName='<tt>"\&#92;uFFFD"<\/tt>' \
	    -DreplType='String' \
	    -DreplFQType='java.lang.String' \
	    -DreplLength='length()' \
	    -DItypesPerOtype='CharsPerByte' \
	    -DnotLegal='not legal for this charset' \
	    -Dotypes-per-itype='chars-per-byte' \
	    -DoutSequence='Unicode character'
	mv $@.tmp $@

GENSRC_CHARSETCODER += $(GENSRC_CHARSETCODER_DST)/CharsetDecoder.java

$(GENSRC_CHARSETCODER_DST)/CharsetEncoder.java: $(GENSRC_CHARSETCODER_TEMPLATE)
	@mkdir -p $(@D)
	rm -f $@.tmp
	$(TOOL_SPP) < $< >$@.tmp \
	    -Kencoder \
	    -DA='An' \
	    -Da='an' \
	    -DCode='Encode' \
	    -Dcode='encode' \
	    -DitypesPhrase='sixteen-bit Unicode characters' \
	    -DotypesPhrase='bytes in a specific charset' \
	    -Ditype='character' \
	    -Dotype='byte' \
	    -DItype='Char' \
	    -DOtype='Byte' \
	    -Dcoder='encoder' \
	    -DCoder='Encoder' \
	    -Dcoding='encoding' \
	    -DOtherCoder='Decoder' \
	    -DreplTypeName='byte array' \
	    -DdefaultRepl='new byte[] { (byte)'"'"\\?"'"' }' \
	    -DdefaultReplName='<tt>{<\/tt>\&nbsp;<tt>(byte)'"'"\\?"'"'<\/tt>\&nbsp;<tt>}<\/tt>' \
	    -DreplType='byte[]' \
	    -DreplFQType='byte[]' \
	    -DreplLength='length' \
	    -DItypesPerOtype='BytesPerChar' \
	    -DnotLegal='not a legal sixteen-bit Unicode sequence' \
	    -Dotypes-per-itype='bytes-per-char' \
	    -DoutSequence='byte sequence in the given charset'
	mv $@.tmp $@

GENSRC_CHARSETCODER += $(GENSRC_CHARSETCODER_DST)/CharsetEncoder.java

$(eval $(call mf_echot,gchardec,"Building t_gchardec..."))

.PHONY: t_gchardec
t_gchardec: | $(call mf_echot_dep,gchardec) $(t_btools) $(GENSRC_CHARSETCODER) \
	;


#----------------------------------------


GENSRC_BUFFER := 

GENSRC_BUFFER_DST := $(jbasegensrcp)/java/nio

GENSRC_BUFFER_SRC := $(jbasep)/share/classes/java/nio

$(GENSRC_BUFFER_DST)/_the.buffer.dir: 
	@echo "Generating buffer classes..."
	@mkdir -p $(@D)
	touch $@

define fixRw
  $1_RW := $2
  $1_rwkey := rw
  ifeq (R, $2)
    $1_rwkey := ro
  endif
endef

define typesAndBits
  # param 1 target
  # param 2 type
  # param 3 BO
  $1_a := a
  $1_A := A

  $1_type := $2

  ifeq ($2, byte)
    $1_x        := b
    $1_Type     := Byte
    $1_fulltype := byte
    $1_Fulltype := Byte
    $1_category := integralType
    $1_LBPV     := 0
  endif

  ifeq ($2, char)
    $1_x        := c
    $1_Type     := Char
    $1_fulltype := character
    $1_Fulltype := Character
    $1_category := integralType
    $1_streams  := streamableType
    $1_streamtype := int
    $1_Streamtype := Int
    $1_LBPV     := 1
  endif

  ifeq ($2, short)
    $1_x        := s
    $1_Type     := Short
    $1_fulltype := short
    $1_Fulltype := Short
    $1_category := integralType
    $1_LBPV     := 1
  endif

  ifeq ($2, int)
    $1_a        := an
    $1_A        := An
    $1_x        := i
    $1_Type     := Int
    $1_fulltype := integer
    $1_Fulltype := Integer
    $1_category := integralType
    $1_LBPV     := 2
  endif

  ifeq ($2, long)
    $1_x        := l
    $1_Type     := Long
    $1_fulltype := long
    $1_Fulltype := Long
    $1_category := integralType
    $1_LBPV     := 3
  endif

  ifeq ($2, float)
    $1_x        := f
    $1_Type     := Float
    $1_fulltype := float
    $1_Fulltype := Float
    $1_category := floatingPointType
    $1_LBPV     := 2
  endif

  ifeq ($2, double)
    $1_x        := d
    $1_Type     := Double
    $1_fulltype := double
    $1_Fulltype := Double
    $1_category := floatingPointType
    $1_LBPV     := 3
  endif

  $1_Swaptype := $$($1_Type)
  $1_memtype := $2
  $1_Memtype := $$($1_Type)

  ifeq ($2, float)
    $1_memtype := int
    $1_Memtype := Int
    ifneq ($3, U)
      $1_Swaptype := Int
      $1_fromBits := Float.intBitsToFloat
      $1_toBits   := Float.floatToRawIntBits
    endif
  endif

  ifeq ($2, double)
    $1_memtype := long
    $1_Memtype := Long
    ifneq ($3, U)
      $1_Swaptype := Long
      $1_fromBits := Double.longBitsToDouble
      $1_toBits   := Double.doubleToRawLongBits
    endif
  endif

  ifeq ($3, S)
    $1_swap := Bits.swap
  endif
endef

define genBinOps
  # param 1 target
  # param 2 type
  # param 3 BO
  # param 4 RW
  # param 5 nbytes
  # param 6 nbytesButOne
  $(call typesAndBits,$1,$2,$3)
  $(call fixRw,$1,$4)
  $1_nbytes := $5
  $1_nbytesButOne := $6
  $1_CMD := $(TOOL_SPP) \
    -Dtype=$$($1_type) \
    -DType=$$($1_Type) \
    -Dfulltype=$$($1_fulltype) \
    -Dmemtype=$$($1_memtype) \
    -DMemtype=$$($1_Memtype) \
    -DfromBits=$$($1_fromBits) \
    -DtoBits=$$($1_toBits) \
    -DLG_BYTES_PER_VALUE=$$($1_LBPV) \
    -DBYTES_PER_VALUE="(1 << $$($1_LBPV))" \
    -Dnbytes=$$($1_nbytes) \
    -DnbytesButOne=$$($1_nbytesButOne) \
    -DRW=$$($1_RW) \
    -K$$($1_rwkey) \
    -Da=$$($1_a) \
    -be
endef

define SetupGenBuffer
  # param 1 is for output file
  # param 2 is template dependency
  # param 3-9 are named args.
  #   type :=
  #   BIN :=
  #   RW := Mutability (R)ead-only (W)ritable
  #   BO := (U)nswapped/(S)wapped/(L)ittle/(B)ig
  #
  $(if $3,$1_$(strip $3))
  $(if $4,$1_$(strip $4))
  $(if $5,$1_$(strip $5))
  $(if $6,$1_$(strip $6))
  $(if $7,$1_$(strip $7))
  $(if $8,$1_$(strip $8))
  $(if $9,$1_$(strip $9))
  $(if $(10),$1_$(strip $(10)))
  $(if $(11),$1_$(strip $(11)))
  $(if $(12),$1_$(strip $(12)))
  $(if $(13),$1_$(strip $(13)))
  $(if $(14),$1_$(strip $(14)))
  $(foreach i,3 4 5 6 7 8 9 10 11 12 13 14 15,$(if $($i),$1_$(strip $($i)))$(newline))
  #$(call LogSetupMacroEntry,SetupGenBuffer($1),$2,$3,$4,$5,$6,$7,$8,$9,$(10),$(11),$(12),$(13),$(14),$(15))
  $(if $(16),$(error Internal makefile error: Too many arguments to SetupGenBuffer, please update GensrcBuffer.gmk))

  $(call fixRw,$1,$$($1_RW))
  $(call typesAndBits,$1,$$($1_type),$$($1_BO))

  $1_DST := $(GENSRC_BUFFER_DST)/$1.java
  $1_SRC := $(GENSRC_BUFFER_SRC)/$(strip $2).java.template
  $1_SRC_BIN := $(GENSRC_BUFFER_SRC)/$(strip $2)-bin.java.template

  $1_DEP := $$($1_SRC)
  ifneq ($$($1_BIN), 1)
    $1_DEP := $$($1_SRC)
    $1_OUT := $$($1_DST)
  else
    $1_DEP += $$($1_SRC) $$($1_SRC_BIN)
    $1_OUT := $(GENSRC_BUFFER_DST)/$1.binop.0.java
  endif

  ifeq ($$($1_BIN), 1)
    $(call genBinOps,$1_char,char,$$($1_BO),$$($1_RW),two,one)
    $(call genBinOps,$1_short,short,$$($1_BO),$$($1_RW),two,one)
    $(call genBinOps,$1_int,int,$$($1_BO),$$($1_RW),four,three)
    $(call genBinOps,$1_long,long,$$($1_BO),$$($1_RW),eight,seven)
    $(call genBinOps,$1_float,float,$$($1_BO),$$($1_RW),four,three)
    $(call genBinOps,$1_double,double,$$($1_BO),$$($1_RW),eight,seven)
  endif

  $$($1_DST): $$($1_DEP) $(GENSRC_BUFFER_DST)/_the.buffer.dir
	$(TOOL_SPP) < $$($1_SRC) > $$($1_OUT).tmp \
	    -K$$($1_type) \
	    -K$$($1_category) \
	    -K$$($1_streams) \
	    -Dtype=$$($1_type) \
	    -DType=$$($1_Type) \
	    -Dfulltype=$$($1_fulltype) \
	    -DFulltype=$$($1_Fulltype) \
	    -Dstreamtype=$$($1_streamtype) \
	    -DStreamtype=$$($1_Streamtype) \
	    -Dx=$$($1_x) \
	    -Dmemtype=$$($1_memtype) \
	    -DMemtype=$$($1_Memtype) \
	    -DSwaptype=$$($1_Swaptype) \
	    -DfromBits=$$($1_fromBits) \
	    -DtoBits=$$($1_toBits) \
	    -DLG_BYTES_PER_VALUE=$$($1_LBPV) \
	    -DBYTES_PER_VALUE="(1 << $$($1_LBPV))" \
	    -DBO=$$($1_BO) \
	    -Dswap=$$($1_swap) \
	    -DRW=$$($1_RW) \
	    -K$$($1_rwkey) \
	    -Da=$$($1_a) \
	    -DA=$$($1_A) \
	    -Kbo$$($1_BO)
	mv $$($1_OUT).tmp $$($1_OUT)
        # Do the extra bin thing
        ifeq ($$($1_BIN), 1)
	  sed -e '/#BIN/,$$$$d' < $$($1_OUT) > $$($1_DST).tmp
	  rm -f $$($1_OUT)
	  $$($1_char_CMD) < $$($1_SRC_BIN) >> $$($1_DST).tmp
	  $$($1_short_CMD) < $$($1_SRC_BIN) >> $$($1_DST).tmp
	  $$($1_int_CMD) < $$($1_SRC_BIN) >> $$($1_DST).tmp
	  $$($1_long_CMD) < $$($1_SRC_BIN) >> $$($1_DST).tmp
	  $$($1_float_CMD) < $$($1_SRC_BIN) >> $$($1_DST).tmp
	  $$($1_double_CMD) < $$($1_SRC_BIN) >> $$($1_DST).tmp
	  printf "}\n" >> $$($1_DST).tmp
	  mv $$($1_DST).tmp $$($1_DST)
        endif

  GENSRC_BUFFER += $$($1_DST)

endef

#

X_BUF := X-Buffer

$(eval $(call SetupGenBuffer,ByteBuffer,  $(X_BUF), type:=byte, BIN:=1))
$(eval $(call SetupGenBuffer,CharBuffer,  $(X_BUF), type:=char))
$(eval $(call SetupGenBuffer,ShortBuffer, $(X_BUF), type:=short))
$(eval $(call SetupGenBuffer,IntBuffer,   $(X_BUF), type:=int))
$(eval $(call SetupGenBuffer,LongBuffer,  $(X_BUF), type:=long))
$(eval $(call SetupGenBuffer,FloatBuffer, $(X_BUF), type:=float))
$(eval $(call SetupGenBuffer,DoubleBuffer,$(X_BUF), type:=double))

# Buffers whose contents are heap-allocated
#
HEAP_X_BUF := Heap-X-Buffer

$(eval $(call SetupGenBuffer,HeapByteBuffer,   $(HEAP_X_BUF), type:=byte))
$(eval $(call SetupGenBuffer,HeapByteBufferR,  $(HEAP_X_BUF), type:=byte, RW:=R))
$(eval $(call SetupGenBuffer,HeapCharBuffer,   $(HEAP_X_BUF), type:=char))
$(eval $(call SetupGenBuffer,HeapCharBufferR,  $(HEAP_X_BUF), type:=char, RW:=R))
$(eval $(call SetupGenBuffer,HeapShortBuffer,  $(HEAP_X_BUF), type:=short))
$(eval $(call SetupGenBuffer,HeapShortBufferR, $(HEAP_X_BUF), type:=short, RW:=R))
$(eval $(call SetupGenBuffer,HeapIntBuffer,    $(HEAP_X_BUF), type:=int))
$(eval $(call SetupGenBuffer,HeapIntBufferR,   $(HEAP_X_BUF), type:=int, RW:=R))
$(eval $(call SetupGenBuffer,HeapLongBuffer,   $(HEAP_X_BUF), type:=long))
$(eval $(call SetupGenBuffer,HeapLongBufferR,  $(HEAP_X_BUF), type:=long, RW:=R))
$(eval $(call SetupGenBuffer,HeapFloatBuffer,  $(HEAP_X_BUF), type:=float))
$(eval $(call SetupGenBuffer,HeapFloatBufferR, $(HEAP_X_BUF), type:=float, RW:=R))
$(eval $(call SetupGenBuffer,HeapDoubleBuffer, $(HEAP_X_BUF), type:=double))
$(eval $(call SetupGenBuffer,HeapDoubleBufferR,$(HEAP_X_BUF), type:=double, RW:=R))

# Direct byte buffer
#
DIRECT_X_BUF := Direct-X-Buffer

$(eval $(call SetupGenBuffer,DirectByteBuffer, $(DIRECT_X_BUF), type:=byte, BIN:=1))
$(eval $(call SetupGenBuffer,DirectByteBufferR,$(DIRECT_X_BUF), type:=byte, BIN:=1, RW:=R))

# Unswapped views of direct byte buffers
#
$(eval $(call SetupGenBuffer,DirectCharBufferU,   $(DIRECT_X_BUF), type:=char, BO:=U))
$(eval $(call SetupGenBuffer,DirectCharBufferRU,  $(DIRECT_X_BUF), type:=char, RW:=R, BO:=U))
$(eval $(call SetupGenBuffer,DirectShortBufferU,  $(DIRECT_X_BUF), type:=short, BO:=U))
$(eval $(call SetupGenBuffer,DirectShortBufferRU, $(DIRECT_X_BUF), type:=short, RW:=R, BO:=U))
$(eval $(call SetupGenBuffer,DirectIntBufferU,    $(DIRECT_X_BUF), type:=int, BO:=U))
$(eval $(call SetupGenBuffer,DirectIntBufferRU,   $(DIRECT_X_BUF), type:=int, RW:=R, BO:=U))
$(eval $(call SetupGenBuffer,DirectLongBufferU,   $(DIRECT_X_BUF), type:=long, BO:=U))
$(eval $(call SetupGenBuffer,DirectLongBufferRU,  $(DIRECT_X_BUF), type:=long, RW:=R, BO:=U))
$(eval $(call SetupGenBuffer,DirectFloatBufferU,  $(DIRECT_X_BUF), type:=float, BO:=U))
$(eval $(call SetupGenBuffer,DirectFloatBufferRU, $(DIRECT_X_BUF), type:=float, RW:=R, BO:=U))
$(eval $(call SetupGenBuffer,DirectDoubleBufferU, $(DIRECT_X_BUF), type:=double, BO:=U))
$(eval $(call SetupGenBuffer,DirectDoubleBufferRU,$(DIRECT_X_BUF), type:=double, RW:=R, BO:=U))

# Swapped views of direct byte buffers
#
$(eval $(call SetupGenBuffer,DirectCharBufferS,   $(DIRECT_X_BUF), type:=char, BO:=S))
$(eval $(call SetupGenBuffer,DirectCharBufferRS,  $(DIRECT_X_BUF), type:=char, RW:=R, BO:=S))
$(eval $(call SetupGenBuffer,DirectShortBufferS,  $(DIRECT_X_BUF), type:=short, BO:=S))
$(eval $(call SetupGenBuffer,DirectShortBufferRS, $(DIRECT_X_BUF), type:=short, RW:=R, BO:=S))
$(eval $(call SetupGenBuffer,DirectIntBufferS,    $(DIRECT_X_BUF), type:=int, BO:=S))
$(eval $(call SetupGenBuffer,DirectIntBufferRS,   $(DIRECT_X_BUF), type:=int, RW:=R, BO:=S))
$(eval $(call SetupGenBuffer,DirectLongBufferS,   $(DIRECT_X_BUF), type:=long, BO:=S))
$(eval $(call SetupGenBuffer,DirectLongBufferRS,  $(DIRECT_X_BUF), type:=long, RW:=R, BO:=S))
$(eval $(call SetupGenBuffer,DirectFloatBufferS,  $(DIRECT_X_BUF), type:=float, BO:=S))
$(eval $(call SetupGenBuffer,DirectFloatBufferRS, $(DIRECT_X_BUF), type:=float, RW:=R, BO:=S))
$(eval $(call SetupGenBuffer,DirectDoubleBufferS, $(DIRECT_X_BUF), type:=double, BO:=S))
$(eval $(call SetupGenBuffer,DirectDoubleBufferRS,$(DIRECT_X_BUF), type:=double, RW:=R, BO:=S))

# Big-endian views of byte buffers
#
BYTE_X_BUF := ByteBufferAs-X-Buffer

$(eval $(call SetupGenBuffer,ByteBufferAsCharBufferB,   $(BYTE_X_BUF), type:=char, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsCharBufferRB,  $(BYTE_X_BUF), type:=char, RW:=R, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsShortBufferB,  $(BYTE_X_BUF), type:=short, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsShortBufferRB, $(BYTE_X_BUF), type:=short, RW:=R, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsIntBufferB,    $(BYTE_X_BUF), type:=int, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsIntBufferRB,   $(BYTE_X_BUF), type:=int, RW:=R, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsLongBufferB,   $(BYTE_X_BUF), type:=long, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsLongBufferRB,  $(BYTE_X_BUF), type:=long, RW:=R, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsFloatBufferB,  $(BYTE_X_BUF), type:=float, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsFloatBufferRB, $(BYTE_X_BUF), type:=float, RW:=R, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsDoubleBufferB, $(BYTE_X_BUF), type:=double, BO:=B))
$(eval $(call SetupGenBuffer,ByteBufferAsDoubleBufferRB,$(BYTE_X_BUF), type:=double, RW:=R, BO:=B))

# Little-endian views of byte buffers
#
$(eval $(call SetupGenBuffer,ByteBufferAsCharBufferL,   $(BYTE_X_BUF), type:=char, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsCharBufferRL,  $(BYTE_X_BUF), type:=char, RW:=R, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsShortBufferL,  $(BYTE_X_BUF), type:=short, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsShortBufferRL, $(BYTE_X_BUF), type:=short, RW:=R, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsIntBufferL,    $(BYTE_X_BUF), type:=int, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsIntBufferRL,   $(BYTE_X_BUF), type:=int, RW:=R, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsLongBufferL,   $(BYTE_X_BUF), type:=long, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsLongBufferRL,  $(BYTE_X_BUF), type:=long, RW:=R, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsFloatBufferL,  $(BYTE_X_BUF), type:=float, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsFloatBufferRL, $(BYTE_X_BUF), type:=float, RW:=R, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsDoubleBufferL, $(BYTE_X_BUF), type:=double, BO:=L))
$(eval $(call SetupGenBuffer,ByteBufferAsDoubleBufferRL,$(BYTE_X_BUF), type:=double, RW:=R, BO:=L))

$(eval $(call mf_echot,gbuffers,"Building t_gbuffers..."))

.PHONY: t_gbuffers
t_gbuffers: | $(call mf_echot_dep,gbuffers) $(t_btools) $(GENSRC_BUFFER) \
	;


#----------------------------------------


GENSRC_EXCEPTIONS :=

GENSRC_EXCEPTIONS_DST := $(jbasegensrcp)/java/nio

GENSRC_EXCEPTIONS_SRC := $(jbasep)/share/classes/java/nio
GENSRC_EXCEPTIONS_CMD := $(jdkmkscriptsp)/genExceptions.sh

GENSRC_EXCEPTIONS_SRC_DIRS := . charset channels

$(GENSRC_EXCEPTIONS_DST)/_the.exceptions.dir:
	@echo "Generating exceptions classes..."
	@mkdir -p $(@D)
	touch $@

$(GENSRC_EXCEPTIONS_DST)/_the.%.marker: $(GENSRC_EXCEPTIONS_SRC)/%/exceptions \
    $(GENSRC_EXCEPTIONS_CMD) \
    $(GENSRC_EXCEPTIONS_DST)/_the.exceptions.dir
	@mkdir -p $(@D)/$*
	SCRIPTS="$(jdkmkscriptsp)" NAWK="awk" SH="sh" sh $(GENSRC_EXCEPTIONS_CMD) $< $(@D)/$*
	touch $@

GENSRC_EXCEPTIONS += $(foreach D,$(GENSRC_EXCEPTIONS_SRC_DIRS),$(GENSRC_EXCEPTIONS_DST)/_the.$(D).marker)

$(eval $(call mf_echot,gexceptions,"Building t_gexceptions..."))

.PHONY: t_gexceptions
t_gexceptions: | $(call mf_echot_dep,gexceptions) $(t_btools) $(GENSRC_EXCEPTIONS) \
	;


#----------------------------------------


define SetupOneCopy-zh_HK
	# 3 -- module
  $1_$2_TARGET := $$(patsubst $(srcp)/$(3)/share/classes/%, \
      $(gensrcp)/$(3)/%, \
      $$(subst _zh_TW,_zh_HK, $2))

  $$($1_$2_TARGET): $2
	@mkdir -p $$(@D)
	cat $$< | sed -e '/class/s/_zh_TW/_zh_HK/' > $$@

  $1 += $$($1_$2_TARGET)
endef

define SetupCopy-zh_HK
	# 3 -- module
  $$(foreach f, $2, $$(eval $$(call SetupOneCopy-zh_HK,$1,$$f,$(3))))
endef

define SetupCompileProperties
	# 4 -- module
  $1_SRCS := $2
  $1_CLASS := $3

  # Convert .../src/<module>/share/classes/com/sun/tools/javac/resources/javac_zh_CN.properties
  # to .../langtools/gensrc/<module>/com/sun/tools/javac/resources/javac_zh_CN.java
  # Strip away prefix and suffix, leaving for example only: 
  # "<module>/share/classes/com/sun/tools/javac/resources/javac_zh_CN"
  $1_JAVAS := $$(patsubst $(srcp)/%, \
      $(gensrcp)/%, \
      $$(patsubst %.properties, %.java, \
      $$(subst /share/classes,, $$($1_SRCS))))

  # Generate the package dirs for the to be generated java files. Sort to remove
  # duplicates.
  $1_DIRS := $$(sort $$(dir $$($1_JAVAS)))

  # Now generate a sequence of:
  # "-compile ...javac_zh_CN.properties ...javac_zh_CN.java java.util.ListResourceBundle"
  # suitable to be fed into the CompileProperties command.
  $1_CMDLINE := $$(subst _SPACE_, $(space), \
      $$(join $$(addprefix -compile_SPACE_, $$($1_SRCS)), \
      $$(addsuffix _SPACE_$$($1_CLASS), \
      $$(addprefix _SPACE_, $$($1_JAVAS)))))

  $1_TARGET := $(gensrcp)/$(4)/_the.$1.done
  $1_CMDLINE_FILE := $(gensrcp)/$(4)/_the.$1.cmdline

  # Now setup the rule for the generation of the resource bundles.
  $$($1_TARGET): $$($1_SRCS) $$($1_JAVAS)
	@mkdir -p $$(@D) $$($1_DIRS)
	@echo Compiling $$(words $$($1_SRCS)) properties into resource bundles for $(4)
	rm -f $$($1_CMDLINE_FILE)
	$$(call ListPathsSafely,$1_CMDLINE,\n, >> $$($1_CMDLINE_FILE))
	$(TOOL_COMPILEPROPERTIES) -quiet @$$($1_CMDLINE_FILE)
	touch $$@

  $$($1_JAVAS): $$($1_SRCS)

  # Create zh_HK versions of all zh_TW files created above
  $$(eval $$(call SetupCopy-zh_HK,$1_HK,$$(filter %_zh_TW.java, $$($1_JAVAS)),$(4)))
  # The zh_HK copy must wait for the compile properties tool to run
  $$($1_HK): $$($1_TARGET)

  $1 += $$($1_JAVAS) $$($1_TARGET) $$($1_HK)
endef

$(eval $(call SetupCompileProperties,LIST_RESOURCE_BUNDLE, \
    $(filter %.properties, \
        $(call CacheFind, $(jbasep)/share/classes/sun/launcher/resources)), \
    ListResourceBundle,java.base))

$(eval $(call SetupCompileProperties,SUN_UTIL, \
    $(filter %.properties, \
        $(call CacheFind, $(jbasep)/share/classes/sun/util/resources)), \
    sun.util.resources.LocaleNamesBundle,java.base))

# Some resources bundles are already present as java files but still need to be
# copied to zh_HK locale.
$(eval $(call SetupCopy-zh_HK,COPY_ZH_HK, \
    $(addprefix $(jbasep)/share/classes/, \
        sun/misc/resources/Messages_zh_TW.java \
        sun/security/util/AuthResources_zh_TW.java \
        sun/security/util/Resources_zh_TW.java),java.base))

$(eval $(call mf_echot,gprops,"Building t_gprops..."))

.PHONY: t_gprops
t_gprops: | $(call mf_echot_dep,gprops) $(t_btools) $(LIST_RESOURCE_BUNDLE) $(SUN_UTIL) $(COPY_ZH_HK) \
	;


#----------------------------------------


java.base_COPY := .icu .dat .spp content-types.properties hijrah-config-islamic-umalqura.properties
java.base_CLEAN := intrinsic.properties

java.base_EXCLUDES += java/lang/doc-files

# Exclude BreakIterator classes that are just used in compile process to generate
# data files and shouldn't go in the product
java.base_EXCLUDE_FILES += sun/text/resources/BreakIteratorRules.java

ifeq ($(mf_target_osx),t)
  JAVA_BASE_UNIX_DIR := $(jbasep)/unix/classes
  # TODO: make JavaCompilation handle overrides automatically instead of excluding here
  # These files are overridden in macosx
  java.base_EXCLUDE_FILES += \
      $(JAVA_BASE_UNIX_DIR)/sun/util/locale/provider/HostLocaleProviderAdapterImpl.java \
      $(JAVA_BASE_UNIX_DIR)/java/net/DefaultInterface.java \
      $(JAVA_BASE_UNIX_DIR)/java/lang/ClassLoaderHelper.java \
      $(JAVA_BASE_UNIX_DIR)/sun/nio/ch/DefaultSelectorProvider.java \
      #
  # This is just skipped on macosx
  java.base_EXCLUDE_FILES += $(JAVA_BASE_UNIX_DIR)/sun/nio/fs/GnomeFileTypeDetector.java
endif

ifneq ($(mf_target_sol),t)
  java.base_EXCLUDE_FILES += \
      SolarisLoginModule.java \
      SolarisSystem.java \
      #
endif

ifeq ($(filter $(mf_target_platform), sol osx aix), )
  #
  # only solaris, macosx and aix
  #
  java.base_EXCLUDE_FILES += sun/nio/fs/PollingWatchService.java
endif

ifeq ($(mf_target_win),t)
  java.base_EXCLUDE_FILES += \
      sun/nio/ch/AbstractPollSelectorImpl.java \
      sun/nio/ch/PollSelectorProvider.java \
      sun/nio/ch/SimpleAsynchronousFileChannelImpl.java \
      #
endif

jdk.charsets_COPY := .dat

sun.charsets_COPY := .dat

jdk.localedata_COPY := _dict _th
# Exclude BreakIterator classes that are just used in compile process to generate
# data files and shouldn't go in the product
jdk.localedata_EXCLUDE_FILES += sun/text/resources/th/BreakIteratorRules_th.java

# Setup the compilation of each module
#
# Do not include nashorn src here since it needs to be compiled separately due
# to nasgen.
#
# Order src dirs in order of override with the most important first. Generated
# source before static source and platform specific source before shared.
#
# To use this variable, use $(call ALL_SRC_DIRS,module) with no space.
GENERATED_SRC_DIRS += $(gensrcp)/$1

OS_SRC_DIRS += $(srcp)/$1/$(OPENJDK_TARGET_OS)/classes
ifneq ($(OPENJDK_TARGET_OS), $(OPENJDK_TARGET_OS_API_DIR))
OS_API_SRC_DIRS += $(srcp)/$1/$(OPENJDK_TARGET_OS_API_DIR)/classes
endif

SHARE_SRC_DIRS += $(srcp)/$1/share/classes

ALL_SRC_DIRS = $(GENERATED_SRC_DIRS) $(OS_SRC_DIRS) $(OS_API_SRC_DIRS) $(SHARE_SRC_DIRS)

ALL_JAVA_MODULES := java.base
JAVA_MODULES := $(ALL_JAVA_MODULES)

.PHONY: COMPILE_ADDITIONAL_COPY
COMPILE_ADDITIONAL_COPY:
	@mkdir -p $(jbasebp)/sun/net/www/
	cp $(jbasep)/$(OPENJDK_TARGET_OS_API_DIR)/classes/sun/net/www/content-types.properties $(jbasebp)/sun/net/www/
	@mkdir -p $(jbasebp)/java/time/chrono/
	cp $(jbasep)/share/classes/java/time/chrono/hijrah-config-islamic-umalqura.properties $(jbasebp)/java/time/chrono/
	@mkdir -p $(jbasebp)/sun/net/idn/
	cp $(jbasep)/share/classes/sun/net/idn/uidna.spp $(jbasebp)/sun/net/idn/
	@mkdir -p $(jbasebp)/sun/text/resources/
	cp $(jbasep)/share/classes/sun/text/resources/ubidi.icu $(jbasebp)/sun/text/resources/
	@mkdir -p $(jbasebp)/sun/text/resources/
	cp $(jbasep)/share/classes/sun/text/resources/unorm.icu $(jbasebp)/sun/text/resources/
	@mkdir -p $(jbasebp)/sun/text/resources/
	cp $(jbasep)/share/classes/sun/text/resources/uprops.icu $(jbasebp)/sun/text/resources/
	@mkdir -p $(jbasebp)/com/sun/java/util/jar/pack/
	cat $(jbasep)/share/classes/com/sun/java/util/jar/pack/intrinsic.properties | \
		sed -e 's/\([^\\]\):/\1\\:/g' -e 's/\([^\\]\)=/\1\\=/g' \
		-e 's/\([^\\]\)!/\1\\!/g' -e 's/#.*/#/g' \
		| sed -f "$(mf_rootp)/../make/common/support/unicode2x.sed" \
		| sed -e '/^#/d' -e '/^$$$$/d' \
		-e :a -e '/\\$$$$/N; s/\\\n//; ta' \
		-e 's/^[ 	]*//;s/[ 	]*$$$$//' \
		-e 's/\\=/=/' | LC_ALL=C sort > $(jbasebp)/com/sun/java/util/jar/pack/intrinsic.properties

JDEP := $(modulesp)/javac.dep
JFILES := $(modulesp)/javac.batch

$(foreach p,$(call ALL_SRC_DIRS,java.base),$(eval $(shell \
	if [ ! -f $(JDEP) ] ; then \
		mkdir -p $$(dirname $(JDEP)); \
		touch $(JDEP); \
	fi; \
	find $(p) -name '*.java' -cnewer $(JDEP) -exec touch $(JDEP) \;$(newline))))

t_jcc_avn_cpp := $(call avnmkfdbprint,cpsrc)
# Assembler, ConstantPool, and Stream are not technically needed for a
# working build, but we include them since our Subroutine test uses
# them to synthesize a class:
define t_jcc_avn_jsrc :=
$(t_jcc_avn_cpp)/avian/Addendum.java
$(t_jcc_avn_cpp)/avian/AnnotationInvocationHandler.java
$(t_jcc_avn_cpp)/avian/Assembler.java
$(t_jcc_avn_cpp)/avian/Callback.java
$(t_jcc_avn_cpp)/avian/Cell.java
$(t_jcc_avn_cpp)/avian/ClassAddendum.java
$(t_jcc_avn_cpp)/avian/Classes.java
$(t_jcc_avn_cpp)/avian/Code.java
$(t_jcc_avn_cpp)/avian/ConstantPool.java
$(t_jcc_avn_cpp)/avian/Continuations.java
$(t_jcc_avn_cpp)/avian/FieldAddendum.java
$(t_jcc_avn_cpp)/avian/Function.java
$(t_jcc_avn_cpp)/avian/IncompatibleContinuationException.java
$(t_jcc_avn_cpp)/avian/InnerClassReference.java
$(t_jcc_avn_cpp)/avian/Machine.java
$(t_jcc_avn_cpp)/avian/MethodAddendum.java
$(t_jcc_avn_cpp)/avian/Pair.java
$(t_jcc_avn_cpp)/avian/Singleton.java
$(t_jcc_avn_cpp)/avian/Stream.java
$(t_jcc_avn_cpp)/avian/SystemClassLoader.java
$(t_jcc_avn_cpp)/avian/Traces.java
$(t_jcc_avn_cpp)/avian/VMClass.java
$(t_jcc_avn_cpp)/avian/VMField.java
$(t_jcc_avn_cpp)/avian/VMMethod.java
$(t_jcc_avn_cpp)/avian/avianvmresource/Handler.java
$(t_jcc_avn_cpp)/avian/file/Handler.java
$(t_jcc_avn_cpp)/sun/net/www/protocol/mem/Handler.java
endef
export t_jcc_avn_jsrc

# TODO: javac -J-Xms64M -J-Xmx1600M -J-XX:ThreadStackSize=1536 -XDignore.symbol.file=true -Xlint:all,-deprecation -Werror
$(JFILES): $(JDEP)
	@mkdir -p $(@D)
	rm -f $(JFILES)
	rm -f $(JFILES).tmp
	rm -rf $(gensrchp)
	$(foreach p,$(call ALL_SRC_DIRS,java.base),find $(p) -name '*.java' >> $(JFILES).tmp;)
	@echo "$$t_jcc_avn_jsrc" >> $(JFILES).tmp
	javac -J-Xms64M -J-Xmx1600M -J-XX:ThreadStackSize=1536 -XDignore.symbol.file=true -Xlint:all,-deprecation -Xlint:-rawtypes \
		-bootclasspath $(jbasebp) \
		-implicit:none \
		$(foreach p,$(call ALL_SRC_DIRS,java.base),-sourcepath $(p)) \
		-d $(jbasebp) \
		-h $(gensrchp) \@$(JFILES).tmp
	#env DEFAULT_METHODS=2 $(call jretrolambda,$(jbasebp),$(jbasebp))
	mv $(JFILES).tmp $(JFILES)

$(eval $(call mf_echot,jcc,"Building t_jcc..."))

.PHONY: t_jcc
t_jcc: | $(call mf_echot_dep,jcc) COMPILE_ADDITIONAL_COPY $(JFILES) \
	;


#----------------------------------------


t_thincompat_jfilesbatch := $(modulesp)/thincompat.javac.batch
$(shell \
	if [ -f $(t_thincompat_jfilesbatch) ] ; then \
		find $(jloggingp)/share/classes -cnewer $(t_thincompat_jfilesbatch) -exec rm -f $(t_thincompat_jfilesbatch) \; ; \
		find $(jxmlp)/share/classes -cnewer $(t_thincompat_jfilesbatch) -exec rm -f $(t_thincompat_jfilesbatch) \; ; \
	fi; )

# t_thincompat_jfiles := \
# 	$(jdesktopp)/share/classes/java/beans/PropertyChangeEvent.java \
# 	$(jdesktopp)/share/classes/java/beans/PropertyChangeListener.java \
# 	$(jdesktopp)/share/classes/java/beans/PropertyVetoException.java \
# 	$(jdesktopp)/share/classes/java/beans/VetoableChangeListener.java \
# 	\
# 	$(shell find $(jloggingp)/share/classes -name '*.java') \
# 	\
# 	$(shell find $(jxmlp)/share/classes -name '*.java') \
# 	#

$(t_thincompat_jfilesbatch):
	mkdir -p $(@D)
	rm -f $(@)
	rm -f $(@).tmp
	rm -rf $(jthincompatbp)
	mkdir -p $(jthincompatbp)
	find \
		$(jdesktopp)/share/classes/java/beans/PropertyChangeEvent.java \
		$(jdesktopp)/share/classes/java/beans/PropertyChangeListener.java \
		$(jdesktopp)/share/classes/java/beans/PropertyVetoException.java \
		$(jdesktopp)/share/classes/java/beans/VetoableChangeListener.java \
		\
		$(jloggingp)/share/classes \
		\
		$(jxmlp)/share/classes \
		\
		-name '*.java' \
		\
		>> $(@).tmp
	#$(if , echo "$(t_thincompat_jfiles)" | tr " " "\n" >> $(@).tmp)
	javac -J-Xms64M -J-Xmx1600M -J-XX:ThreadStackSize=1536 -XDignore.symbol.file=true -Xlint:all,-deprecation -Xlint:-rawtypes \
		-bootclasspath $(jbasebp) \
		-implicit:none \
		-d $(jthincompatbp) \
		\@$(@).tmp
	#env DEFAULT_METHODS=2 $(call jretrolambda,$(jthincompatbp),$(jthincompatbp):$(jbasebp))
	mv $(@).tmp $(@)

$(eval $(call mf_echot,thincompat,"Building t_thincompat..."))

.PHONY: t_thincompat
t_thincompat: | $(t_jcc) $(call mf_echot_dep,thincompat) $(t_thincompat_jfilesbatch) \
	;


#----------------------------------------


t_emb_outp := $(jembbp)

.PHONY: _t_emb_do
_t_emb_do:
	mkdir -p $(t_emb_outp)
	rm -rf $(t_emb_outp)/*
	cp -r $(myemb)/* $(t_emb_outp)

$(eval $(call mf_echot,emb,"Building t_emb..."))

.PHONY: t_emb
t_emb: | $(call mf_echot_dep,emb) _t_emb_do \
	;


#----------------------------------------


BI_TEXT_SRCDIR = $(jbasep)/share/classes \
    $(jlocaledatap)/share/classes
BI_TEXT_PKG = sun/text/resources
BI_TEXT_SOURCES = $(BI_TEXT_PKG)/BreakIteratorRules.java \
    $(BI_TEXT_PKG)/BreakIteratorInfo.java \
    $(BI_TEXT_PKG)/th/BreakIteratorRules_th.java \
    $(BI_TEXT_PKG)/th/BreakIteratorInfo_th.java

BREAK_ITERATOR_DIR = $(buildp)/break_iterator
BREAK_ITERATOR_CLASSES = $(BREAK_ITERATOR_DIR)/classes

BI_SRC := \
	$(jbasep)/share/classes/sun/text/resources/BreakIteratorInfo.java \
	$(jbasep)/share/classes/sun/text/resources/BreakIteratorRules.java \
	$(jlocaledatap)/share/classes/sun/text/resources/th/BreakIteratorInfo_th.java \
	$(jlocaledatap)/share/classes/sun/text/resources/th/BreakIteratorRules_th.java

.PHONY: BUILD_BREAKITERATOR
BUILD_BREAKITERATOR: $(BI_SRC)
	@mkdir -p $(BREAK_ITERATOR_CLASSES)
	$(mf_javac) -bootclasspath $(mf_java_rtjar) -Xlint:all,-deprecation,-unchecked,-rawtypes,-cast,-serial,-dep-ann,-static,-fallthrough,-try,-varargs,-empty,-finally -implicit:none -sourcepath "$(jbasep)/share/classes/sun/text/resources:$(jlocaledatap)/share/classes/sun/text/resources" -d $(BREAK_ITERATOR_CLASSES) $(BI_SRC)

BI_UNICODEDATA = $(jdkmkdatap)/unicodedata/UnicodeData.txt

BI_BASE_DATA_PKG_DIR = $(jbasebp)/sun/text/resources
SL_DATA_PKG_DIR = $(jlocaledatabp)/sun/text/resources
BIFILES = $(BI_BASE_DATA_PKG_DIR)/CharacterBreakIteratorData \
    $(BI_BASE_DATA_PKG_DIR)/WordBreakIteratorData \
    $(BI_BASE_DATA_PKG_DIR)/LineBreakIteratorData \
    $(BI_BASE_DATA_PKG_DIR)/SentenceBreakIteratorData
BIFILES_TH = $(SA_DATA_PKG_DIR)/th/WordBreakIteratorData_th \
    $(SA_DATA_PKG_DIR)/th/LineBreakIteratorData_th

$(BIFILES): $(BREAK_ITERATOR_CLASSES)/_the.bifiles
#$(BI_BASE_DATA_PKG_DIR)/_the.bifiles: JAVA_FLAGS += -Xbootclasspath/p:$(BREAK_ITERATOR_CLASSES)
$(BREAK_ITERATOR_CLASSES)/_the.bifiles: $(BI_UNICODEDATA) BUILD_BREAKITERATOR
	@echo "Generating BreakIteratorData..."
	@mkdir -p $(BI_BASE_DATA_PKG_DIR)
	rm -f $(BIFILES)
	$(mf_java) -XX:+UseSerialGC -Xms32M -Xmx512M -Xbootclasspath/p:$(BREAK_ITERATOR_CLASSES) -cp $(t_btools_outp) $(TOOL_GENERATEBREAKITERATORDATA) \
	    -o $(BI_BASE_DATA_PKG_DIR) \
	    -spec $(BI_UNICODEDATA)
	touch $@

$(BIFILES_TH): $(BREAK_ITERATOR_CLASSES)/_the.bifiles_th
#$(SL_DATA_PKG_DIR)/_the.bifiles_th: JAVA_FLAGS += -Xbootclasspath/p:$(BREAK_ITERATOR_CLASSES)
$(BREAK_ITERATOR_CLASSES)/_the.bifiles_th: $(BI_UNICODEDATA) BUILD_BREAKITERATOR
	@echo "Generating BreakIteratorData_th..."
	@mkdir -p $(SL_DATA_PKG_DIR)/th
	rm -f $(BIFILES_TH)
	$(mf_java) -XX:+UseSerialGC -Xms32M -Xmx512M -Xbootclasspath/p:$(BREAK_ITERATOR_CLASSES) -cp $(t_btools_outp) $(TOOL_GENERATEBREAKITERATORDATA) \
	    -o $(SL_DATA_PKG_DIR) \
	    -spec $(BI_UNICODEDATA) \
	    -language th
	touch $@

TZDATA_DIR := $(jdkmkdatap)/tzdata
TZDATA_TZFILE := africa antarctica asia australasia europe northamerica pacificnew southamerica backward etcetera gmt jdk11_backward
TZDATA_TZFILES := $(addprefix $(TZDATA_DIR)/,$(TZDATA_TZFILE))

GENDATA_TZDB_DAT := $(lib)/tzdb.dat

$(GENDATA_TZDB_DAT): $(TZDATA_TZFILES)
	@echo "Generating tzdata..."
	@mkdir -p $(@D)
	rm -f $(GENDATA_TZDB_DAT)
	$(TOOL_TZDB) -srcdir $(TZDATA_DIR) -dstfile $(GENDATA_TZDB_DAT) $(TZDATA_TZFILE)

GENDATA_BLACKLISTED_CERTS_SRC := $(jdkmkdatap)/blacklistedcertsconverter/blacklisted.certs.pem
GENDATA_BLACKLISTED_CERTS := $(lib)/security/blacklisted.certs
 
$(GENDATA_BLACKLISTED_CERTS): $(GENDATA_BLACKLISTED_CERTS_SRC)
	@echo "Generating blacklisted certs..."
	@mkdir -p $(@D)
	(cat $(GENDATA_BLACKLISTED_CERTS_SRC) | $(TOOL_BLACKLISTED_CERTS) > $@) || exit 1

GENDATA_UNINAME := $(jbasebp)/java/lang/uniName.dat

$(GENDATA_UNINAME): $(jdkmkdatap)/unicodedata/UnicodeData.txt
	@mkdir -p $(@D)
	$(TOOL_CHARACTERNAME) $< $@

GENDATA_CURDATA := $(jbasebp)/java/util/currency.data

$(GENDATA_CURDATA): $(jdkmkdatap)/currency/CurrencyData.properties
	@mkdir -p $(@D)
	rm -f $@
	$(TOOL_GENERATECURRENCYDATA) -o $@.tmp < $<
	mv $@.tmp $@
	chmod 444 $@

GENDATA_JAVA_SECURITY_SRC := $(jbasep)/share/conf/security/java.security
GENDATA_JAVA_SECURITY := $(lib)/security/java.security

# RESTRICTED_PKGS_SRC is optionally set in custom extension for this makefile

$(GENDATA_JAVA_SECURITY): $(GENDATA_JAVA_SECURITY_SRC) $(RESTRICTED_PKGS_SRC)
	@echo "Generating java.security..."
	@mkdir -p $(@D)
	$(TOOL_MAKEJAVASECURITY) $(GENDATA_JAVA_SECURITY_SRC) $@ $(OPENJDK_TARGET_OS) \
		$(RESTRICTED_PKGS_SRC) || exit 1

$(eval $(call mf_echot,gjavad,"Building t_gjavad..."))

.PHONY: t_gjavad
t_gjavad: | $(call mf_echot_dep,gjavad) $(BIFILES) $(BIFILES_TH) $(GENDATA_TZDB_DAT) $(GENDATA_BLACKLISTED_CERTS) $(GENDATA_UNINAME) $(GENDATA_CURDATA) $(GENDATA_JAVA_SECURITY) \
	;


#----------------------------------------


# Workaround on automatic dep gen.
# Ugh.
com_sun_%.h: ;
java_%.h: ;
jdk_%.h: ;
sun_%.h: ;

t_nlibs_buildp = $(buildp)/nlibs

t_nlibs_flags_opts :=
t_nlibs_flags_opts := \
	$(call avnmkfdbprint,t_vm_flags_opts) \

t_nlibs_flags_defs :=
t_nlibs_flags_defs := \
	-D_JNI_IMPLEMENTATION_ \
	-DRELEASE='"1.9.0"' \
	-DJDK_MAJOR_VERSION='"1"' -DJDK_MINOR_VERSION='"9"' -DJDK_MICRO_VERSION='"0"' -DJDK_BUILD_NUMBER='"0"' \
	-D_REENTRANT \
	-D_LARGEFILE64_SOURCE \
	-D_GNU_SOURCE \
	#

t_nlibs_flags_etc :=
t_nlibs_flags_etc := \
	-Wall -Wno-parentheses -Wextra -Wno-unused -Wno-unused-parameter -Wformat=2 -pipe \

#	$(call mf_cc_inco,$(mf_default_cc_nm),$(jbasep)/share/native/libnet) \
#	$(call mf_cc_inco,$(mf_default_cc_nm),$(jmanagementp)/share/native/libmanagement) \
t_nlibs_flags_inc := 
t_nlibs_flags_inc := \
	$(call mf_cc_inco,$(mf_default_cc_nm),$(call avnmkfdbprint,cphp_incp)) \
	$(call mf_cc_inco,$(mf_default_cc_nm),$(call avnmkfdbprint,jdkincp)) \
	$(call mf_cc_inco,$(mf_default_cc_nm),$(jbasep)/$(OPENJDK_TARGET_OS)/native/include) \
	$(call mf_cc_inco,$(mf_default_cc_nm),$(jbasep)/$(OPENJDK_TARGET_OS_API_DIR)/native/include) \
	$(call mf_cc_inco,$(mf_default_cc_nm),$(gensrchp))

ifeq ($(mf_target_x64),t)
	t_nlibs_flags_opts += -m64
	t_nlibs_flags_defs += -D_LP64=1
else ifeq ($(mf_target_x86),t)
	t_nlibs_flags_opts += -m32
endif

ifeq ($(mf_target_x64),t)
	ifeq ($(mf_target_osx),t)
		t_nlibs_flags_defs += -DARCHPROPNAME='"amd64"'
	else
		t_nlibs_flags_defs += -DARCHPROPNAME='"x86_64"'
	endif
	t_nlibs_flags_defs += -D_AMD64_
else ifeq ($(mf_target_x86)$(mf_target_ems),t)
	ifeq ($(mf_target_tux),t)
		t_nlibs_flags_defs += -DARCHPROPNAME='"i386"'
	else
		t_nlibs_flags_defs += -DARCHPROPNAME='"x86"'
	endif
	t_nlibs_flags_defs += -D_X86_ -Dx86
endif

ifeq ($(mf_host_bo_le),t)
	t_nlibs_flags_defs += -D_LITTLE_ENDIAN
else
	t_nlibs_flags_defs += -D_BIG_ENDIAN
endif

ifeq ($(mf_target_tux)$(mf_target_ems),t)
	t_nlibs_flags_defs += -DLINUX
endif

ifeq ($(mf_target_osx),t)
	t_nlibs_flags_defs += -D_ALLBSD_SOURCE
endif

ifeq ($(mf_target_ems),t)
	t_nlibs_flags_defs += -D__linux__
	t_nlibs_flags_defs += -Wno-$(hash)warnings
	t_nlibs_flags_etc += -Wno-warn-absolute-paths
endif

ifeq ($(mf_target_ios),t)
	t_nlibs_flags_defs += _myavn_management_ios
endif

t_nlibs_cc := $(mf_default_cc)
t_nlibs_cc_flags := 

t_nlibs_cxx := $(mf_default_cxx)
t_nlibs_cxx_flags := 

#-Wall -Wno-parentheses -Wextra -Wno-unused -Wno-unused-parameter -Wformat=2 -pipe -D_GNU_SOURCE -D_REENTRANT -D_LARGEFILE64_SOURCE -fno-omit-frame-pointer -D_LP64=1 -D_LITTLE_ENDIAN -DLINUX -DARCH='"amd64"' -Damd64 -DNDEBUG -DRELEASE='"1.9.0-internal"' -I/letmp/myjdktop/jdk/src/java.base/share/native/include -I/letmp/myjdktop/jdk/src/java.base/linux/native/include -I/letmp/myjdktop/jdk/src/java.base/unix/native/include -fno-strict-aliasing -fPIC -I/letmp/myjdktop/jdk/src/java.base/share/native/libfdlibm

#-Wall -Wno-parentheses -Wextra -Wno-unused -Wno-unused-parameter -Wformat=2 -pipe -D_GNU_SOURCE -D_REENTRANT -D_LARGEFILE64_SOURCE -fno-omit-frame-pointer -D_LP64=1 -D_LITTLE_ENDIAN -DLINUX -DARCH='"amd64"' -Damd64 -DNDEBUG -DRELEASE='"1.9.0-internal"' -I/letmp/myjdktop/jdk/src/java.base/share/native/include -I/letmp/myjdktop/jdk/src/java.base/linux/native/include -I/letmp/myjdktop/jdk/src/java.base/unix/native/include -fno-strict-aliasing -fPIC -I/letmp/myjdktop/jdk/src/java.base/unix/native/libjava -I/letmp/myjdktop/jdk/src/java.base/share/native/libjava -I/letmp/myjdktop/jdk/src/java.base/share/native/libfdlibm -I/letmp/myjdktop/build/linux-x86_64-normal-server-release/jdk/gensrc_headers/java.base -DARCHPROPNAME='"amd64"' -DJDK_MAJOR_VERSION='"1"' -DJDK_MINOR_VERSION='"9"' -DJDK_MICRO_VERSION='"0"' -DJDK_BUILD_NUMBER='"b00"'

#
t_nlibs_alldeps := \
	#$(libmkf) \
	#$(avnmkf) \
	#$(mf_rootp)/makefile
	#$(shell find $(jbasep) -name '*.h' -or -name '*.c' -or -name '*.cpp') \
	#$(shell find $(call avnmkfdbprint,mf_rootp) -name '*.h' -or -name '*.c' -or -name '*.cpp') \

#
t_nlibs_lm_p := $(jbasep)/share/native/libfdlibm
t_nlibs_lm_op := $(t_nlibs_buildp)/lm
t_nlibs_lm_f_opts := $(t_nlibs_flags_opts) -fno-strict-aliasing
t_nlibs_lm_f_defs := $(t_nlibs_flags_defs)
t_nlibs_lm_f_etc := $(t_nlibs_flags_etc) -Wformat=2
t_nlibs_lm_f_inc := $(t_nlibs_flags_inc) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lm_p))
t_nlibs_lm_f_all := $(t_nlibs_lm_f_opts) $(t_nlibs_lm_f_defs) $(t_nlibs_lm_f_etc) $(t_nlibs_lm_f_inc)
t_nlibs_lm_src := $(wildcard $(t_nlibs_lm_p)/*.c)
t_nlibs_lm_objs := $(call mf_cobjs,$(t_nlibs_lm_src),$(t_nlibs_lm_p),$(t_nlibs_lm_op),mf_binname_obj,$(mf_target_platform))

$(t_nlibs_lm_objs): $(t_nlibs_lm_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_lm_f_defs)$(space)$(t_nlibs_lm_f_inc),$(t_nlibs_lm_p)/%.c) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lm_f_all))

#
t_nlibs_lj_p1 := $(jbasep)/share/native/libjava
t_nlibs_lj_p2 := $(jbasep)/$(OPENJDK_TARGET_OS)/native/libjava
t_nlibs_lj_p3 := $(jbasep)/$(OPENJDK_TARGET_OS_API_DIR)/native/libjava
ifeq ($(t_nlibs_lj_p2),$(t_nlibs_lj_p3))
	override t_nlibs_lj_p3 :=
endif
t_nlibs_lj_op := $(t_nlibs_buildp)/lj
t_nlibs_lj_f_opts := $(t_nlibs_flags_opts) -fno-strict-aliasing
t_nlibs_lj_f_defs := $(t_nlibs_flags_defs)
t_nlibs_lj_f_etc := $(t_nlibs_flags_etc)
t_nlibs_lj_f_inc := $(t_nlibs_flags_inc) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lm_p)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p2)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p3))
t_nlibs_lj_f_all := $(t_nlibs_lj_f_opts) $(t_nlibs_lj_f_defs) $(t_nlibs_lj_f_etc) $(t_nlibs_lj_f_inc)
t_nlibs_lj_src1 := $(wildcard $(t_nlibs_lj_p1)/*.c)
t_nlibs_lj_src2 := $(wildcard $(t_nlibs_lj_p2)/*.c)
t_nlibs_lj_src3 := $(wildcard $(t_nlibs_lj_p3)/*.c)
t_nlibs_lj_objs1 := $(call mf_cobjs,$(t_nlibs_lj_src1),$(t_nlibs_lj_p1),$(t_nlibs_lj_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lj_objs2 := $(call mf_cobjs,$(t_nlibs_lj_src2),$(t_nlibs_lj_p2),$(t_nlibs_lj_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lj_objs3 := $(call mf_cobjs,$(t_nlibs_lj_src3),$(t_nlibs_lj_p3),$(t_nlibs_lj_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lj_objs_all := $(t_nlibs_lj_objs1) $(t_nlibs_lj_objs2) $(t_nlibs_lj_objs3)

$(t_nlibs_lj_objs1): $(t_nlibs_lj_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_lj_f_defs)$(space)$(t_nlibs_lj_f_inc),$(t_nlibs_lj_p1)/%.c) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lj_f_all))

ifeq ($(mf_target_osx),t)
define t_nlibs_lj_compile =
	if [ $(<F) == java_props_md.c ] || [ $(<F) == java_props_macosx.c ] ; then \
		$(call mf_compileobj,$(t_nlibs_cc),-x$(space)objective-c$(space)$(t_nlibs_lj_f_all)) \
	else \
		$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lj_f_all)) \
	fi ;
endef
else
define t_nlibs_lj_compile =
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lj_f_all))
endef
endif

ifneq ($(t_nlibs_lj_objs2),)
$(t_nlibs_lj_objs2): $(t_nlibs_lj_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_lj_f_defs)$(space)$(t_nlibs_lj_f_inc),$(t_nlibs_lj_p2)/%.c) $(t_nlibs_alldeps)
	$(call t_nlibs_lj_compile)
endif

ifneq ($(t_nlibs_lj_objs3),)
$(t_nlibs_lj_objs3): $(t_nlibs_lj_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_lj_f_defs)$(space)$(t_nlibs_lj_f_inc),$(t_nlibs_lj_p3)/%.c) $(t_nlibs_alldeps)
	$(call t_nlibs_lj_compile)
endif

#
t_nlibs_lz_p1 := $(jbasep)/share/native/libzip
t_nlibs_lz_p2 := $(jbasep)/share/native/libzip/zlib-1.2.8
t_nlibs_lz_op := $(t_nlibs_buildp)/lz
t_nlibs_lz_f_opts := $(filter-out -O3,$(t_nlibs_flags_opts)) -O0 $(if $(mf_target_ems),--js-opts$(space)0) -fno-strict-aliasing
t_nlibs_lz_f_defs := $(t_nlibs_flags_defs)
t_nlibs_lz_f_etc := $(t_nlibs_flags_etc)
t_nlibs_lz_f_inc := $(t_nlibs_flags_inc) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p2)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p3)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lz_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lz_p2))
t_nlibs_lz_f_all := $(t_nlibs_lz_f_opts) $(t_nlibs_lz_f_defs) $(t_nlibs_lz_f_etc) $(t_nlibs_lz_f_inc)
t_nlibs_lz_src1 := $(wildcard $(t_nlibs_lz_p1)/*.c)
t_nlibs_lz_src2 := $(wildcard $(t_nlibs_lz_p2)/*.c)
t_nlibs_lz_objs1 := $(call mf_cobjs,$(t_nlibs_lz_src1),$(t_nlibs_lz_p1),$(t_nlibs_lz_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lz_objs2 := $(call mf_cobjs,$(t_nlibs_lz_src2),$(t_nlibs_lz_p2),$(t_nlibs_lz_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lz_objs_all := $(t_nlibs_lz_objs1) $(t_nlibs_lz_objs2)

$(t_nlibs_lz_objs1): $(t_nlibs_lz_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_lz_f_defs)$(space)$(t_nlibs_lz_f_inc),$(t_nlibs_lz_p1)/%.c) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lz_f_all))

$(t_nlibs_lz_objs2): $(t_nlibs_lz_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_lz_f_defs)$(space)$(t_nlibs_lz_f_inc),$(t_nlibs_lz_p2)/%.c) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lz_f_all))

#
t_nlibs_lnet_p1 := $(jbasep)/share/native/libnet
t_nlibs_lnet_p2 := $(if $(mf_target_ems), ,$(jbasep)/$(OPENJDK_TARGET_OS)/native/libnet)
t_nlibs_lnet_p3 := $(jbasep)/$(OPENJDK_TARGET_OS_API_DIR)/native/libnet
ifeq ($(t_nlibs_lnet_p2),$(t_nlibs_lnet_p3))
	override t_nlibs_lnet_p3 :=
endif
t_nlibs_lnet_op := $(t_nlibs_buildp)/lnet
t_nlibs_lnet_f_opts := $(t_nlibs_flags_opts) -fno-strict-aliasing
t_nlibs_lnet_f_defs := $(t_nlibs_flags_defs)
t_nlibs_lnet_f_etc := $(t_nlibs_flags_etc)
t_nlibs_lnet_f_inc := $(t_nlibs_flags_inc) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p2)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p3)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnet_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnet_p2)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnet_p3))
t_nlibs_lnet_f_all := $(t_nlibs_lnet_f_opts) $(t_nlibs_lnet_f_defs) $(t_nlibs_lnet_f_etc) $(t_nlibs_lnet_f_inc)
t_nlibs_lnet_src1 := $(wildcard $(t_nlibs_lnet_p1)/*.c)
t_nlibs_lnet_src2 := $(wildcard $(t_nlibs_lnet_p2)/*.c)
t_nlibs_lnet_src3 := $(wildcard $(t_nlibs_lnet_p3)/*.c)
t_nlibs_lnet_objs1 := $(call mf_cobjs,$(t_nlibs_lnet_src1),$(t_nlibs_lnet_p1),$(t_nlibs_lnet_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lnet_objs2 := $(call mf_cobjs,$(t_nlibs_lnet_src2),$(t_nlibs_lnet_p2),$(t_nlibs_lnet_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lnet_objs3 := $(call mf_cobjs,$(t_nlibs_lnet_src3),$(t_nlibs_lnet_p3),$(t_nlibs_lnet_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lnet_objs_all := $(t_nlibs_lnet_objs1) $(t_nlibs_lnet_objs2) $(t_nlibs_lnet_objs3)

$(t_nlibs_lnet_objs1): $(t_nlibs_lnet_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_net_f_defs)$(space)$(t_nlibs_lnet_f_inc),$(t_nlibs_lnet_p1)/%.c) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lnet_f_all))

ifneq ($(t_nlibs_lnet_objs2),)
$(t_nlibs_lnet_objs2): $(t_nlibs_lnet_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_lnet_f_defs)$(space)$(t_nlibs_lnet_f_inc),$(t_nlibs_lnet_p2)/%.c) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lnet_f_all))
endif

ifneq ($(t_nlibs_lnet_objs3),)
$(t_nlibs_lnet_objs3): $(t_nlibs_lnet_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_lnet_f_defs)$(space)$(t_nlibs_lnet_f_inc),$(t_nlibs_lnet_p3)/%.c) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lnet_f_all))
endif

#
t_nlibs_lnio_p1 := $(jbasep)/share/native/libnio
t_nlibs_lnio_p2 := $(jbasep)/$(OPENJDK_TARGET_OS)/native/libnio
t_nlibs_lnio_p3 := $(jbasep)/$(OPENJDK_TARGET_OS_API_DIR)/native/libnio
ifeq ($(t_nlibs_lnio_p2),$(t_nlibs_lnio_p3))
	override t_nlibs_lnio_p3 :=
else
	t_nlibs_lnio_p3_ch := $(t_nlibs_lnio_p3)/ch
	t_nlibs_lnio_p3_fs := $(t_nlibs_lnio_p3)/fs
endif
t_nlibs_lnio_op := $(t_nlibs_buildp)/lnio
t_nlibs_lnio_f_opts := $(t_nlibs_flags_opts) -fno-strict-aliasing
t_nlibs_lnio_f_defs := $(t_nlibs_flags_defs)
t_nlibs_lnio_f_etc := $(t_nlibs_flags_etc)
t_nlibs_lnio_f_inc := $(t_nlibs_flags_inc) \
	$(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnio_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnio_p1))/ch $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnio_p1))/fs $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnio_p2)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnio_p2))/ch $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnio_p2))/fs $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnio_p3)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnio_p3_ch)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnio_p3_fs)) \
	\
	$(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p2)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p3)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnet_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnet_p2)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lnet_p3))
t_nlibs_lnio_f_all := $(t_nlibs_lnio_f_opts) $(t_nlibs_lnio_f_defs) $(t_nlibs_lnio_f_etc) $(t_nlibs_lnio_f_inc)
t_nlibs_lnio_src1 := $(wildcard $(t_nlibs_lnio_p1)/*.c) $(wildcard $(t_nlibs_lnio_p1)/ch/*.c) $(wildcard $(t_nlibs_lnio_p1)/fs/*.c)
t_nlibs_lnio_src2 := $(if $(t_nlibs_lnio_p2),$(wildcard $(t_nlibs_lnio_p2)/*.c) $(wildcard $(t_nlibs_lnio_p2)/ch/*.c) $(wildcard $(t_nlibs_lnio_p2)/fs/*.c))
t_nlibs_lnio_src3 := $(if $(t_nlibs_lnio_p3),$(wildcard $(t_nlibs_lnio_p3)/*.c) $(wildcard $(t_nlibs_lnio_p3_ch)/*.c) $(wildcard $(t_nlibs_lnio_p3_fs)/*.c))
t_nlibs_lnio_objs1 := $(call mf_cobjs,$(t_nlibs_lnio_src1),$(t_nlibs_lnio_p1),$(t_nlibs_lnio_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lnio_objs2 := $(call mf_cobjs,$(t_nlibs_lnio_src2),$(t_nlibs_lnio_p2),$(t_nlibs_lnio_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lnio_objs3 := $(call mf_cobjs,$(t_nlibs_lnio_src3),$(t_nlibs_lnio_p3),$(t_nlibs_lnio_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lnio_objs_all := $(t_nlibs_lnio_objs1) $(t_nlibs_lnio_objs2) $(t_nlibs_lnio_objs3)

$(t_nlibs_lnio_objs1): $(t_nlibs_lnio_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_nio_f_defs)$(space)$(t_nlibs_lnio_f_inc),$(t_nlibs_lnio_p1)/%.c) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lnio_f_all))

ifneq ($(t_nlibs_lnio_objs2),)
$(t_nlibs_lnio_objs2): $(t_nlibs_lnio_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_lnio_f_defs)$(space)$(t_nlibs_lnio_f_inc),$(t_nlibs_lnio_p2)/%.c) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lnio_f_all))
endif

ifneq ($(t_nlibs_lnio_objs3),)
$(t_nlibs_lnio_objs3): $(t_nlibs_lnio_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cc),$(t_nlibs_lnio_f_defs)$(space)$(t_nlibs_lnio_f_inc),$(t_nlibs_lnio_p3)/%.c) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cc),$(t_nlibs_lnio_f_all))
endif

#
t_nlibs_lunpack_p1 := $(jjdkruntimep)/share/native/common-unpack
t_nlibs_lunpack_p2 := $(jjdkruntimep)/share/native/libunpack
t_nlibs_lunpack_op := $(t_nlibs_buildp)/lunpack
t_nlibs_lunpack_f_opts := $(filter-out -O3,$(t_nlibs_flags_opts)) -O0 $(if $(mf_target_ems),--js-opts$(space)0) -fno-strict-aliasing
t_nlibs_lunpack_f_defs := $(t_nlibs_flags_defs) -D_cph_cfg_basic_szof_check=0
t_nlibs_lunpack_f_etc := $(t_nlibs_flags_etc)
t_nlibs_lunpack_f_inc := $(t_nlibs_flags_inc) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p2)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lj_p3)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lz_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lz_p2)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lunpack_p1)) $(call mf_cc_inco,$(mf_default_cc_nm),$(t_nlibs_lunpack_p2))
t_nlibs_lunpack_f_all := $(t_nlibs_lunpack_f_opts) $(t_nlibs_lunpack_f_defs) $(t_nlibs_lunpack_f_etc) $(t_nlibs_lunpack_f_inc)
t_nlibs_lunpack_src1 := $(wildcard $(t_nlibs_lunpack_p1)/*.cpp)
t_nlibs_lunpack_src2 := $(wildcard $(t_nlibs_lunpack_p2)/*.cpp)
t_nlibs_lunpack_objs1 := $(call mf_cppobjs,$(t_nlibs_lunpack_src1),$(t_nlibs_lunpack_p1),$(t_nlibs_lunpack_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lunpack_objs2 := $(call mf_cppobjs,$(t_nlibs_lunpack_src2),$(t_nlibs_lunpack_p2),$(t_nlibs_lunpack_op),mf_binname_obj,$(mf_target_platform))
t_nlibs_lunpack_objs_all := $(t_nlibs_lunpack_objs1) $(t_nlibs_lunpack_objs2)

$(t_nlibs_lunpack_objs1): $(t_nlibs_lunpack_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cxx),$(t_nlibs_lunpack_f_defs)$(space)$(t_nlibs_lunpack_f_inc),$(t_nlibs_lunpack_p1)/%.cpp) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cxx),$(t_nlibs_lunpack_f_all))

$(t_nlibs_lunpack_objs2): $(t_nlibs_lunpack_op)/$(call mf_binname_obj,$(call mf_binname_plat,$(mf_target_platform)),%): $$(call mf_srcdepends,$(t_nlibs_cxx),$(t_nlibs_lunpack_f_defs)$(space)$(t_nlibs_lunpack_f_inc),$(t_nlibs_lunpack_p2)/%.cpp) $(t_nlibs_alldeps)
	$(call mf_compileobj,$(t_nlibs_cxx),$(t_nlibs_lunpack_f_all))

#
jdkobjs := $(t_nlibs_lm_objs) $(t_nlibs_lj_objs_all) $(t_nlibs_lz_objs_all) $(t_nlibs_lnet_objs_all) $(t_nlibs_lnio_objs_all) $(t_nlibs_lunpack_objs_all)

$(eval $(call mf_echot,nlibs,"Building t_nlibs..."))

.PHONY: t_nlibs
t_nlibs: | $(call mf_echot_dep,nlibs) $(t_nlibs_lm_objs) $(t_nlibs_lz_objs_all) $(t_nlibs_lj_objs_all) $(t_nlibs_lnet_objs_all) $(t_nlibs_lnio_objs_all) $(t_nlibs_lunpack_objs_all) \
	;


#----------------------------------------


t_img_rp := $(mf_resultp)
t_img_r_jar := $(t_img_rp)/myjdk.jar
t_img_r_h := $(t_img_rp)/myjdkjar.gen.h
t_img_r_m := $(t_img_rp)/myjdkjni.gen.inc.cpp
t_img_r_m_src := \
	$(call avnmkfdbprint,t_vm_src_cp1) $(call avnmkfdbprint,t_vm_src_cp2) \
	\
	$(t_nlibs_lm_src) \
	$(t_nlibs_lj_src1) $(t_nlibs_lj_src2) $(t_nlibs_lj_src3) \
	$(t_nlibs_lz_src1) $(t_nlibs_lz_src2) \
	$(t_nlibs_lnet_src1) $(t_nlibs_lnet_src2) $(t_nlibs_lnet_src3) \
	$(t_nlibs_lnio_src1) $(t_nlibs_lnio_src2) $(t_nlibs_lnio_src3) \
	$(t_nlibs_lunpack_src1) $(t_nlibs_lunpack_src2) \
	#
t_img_r_m_f := \
	$(call avnmkfdbprint,t_vm_flags_defs) $(call avnmkfdbprint,t_vm_flags_inc) \
	\
	$(t_nlibs_lm_f_defs) $(t_nlibs_lm_f_inc) \
	$(t_nlibs_lj_f_defs) $(t_nlibs_lj_f_inc) \
	$(t_nlibs_lz_f_defs) $(t_nlibs_lz_f_inc) \
	$(t_nlibs_lnet_f_defs) $(t_nlibs_lnet_f_inc) \
	$(t_nlibs_lnio_f_defs) $(t_nlibs_lnio_f_inc) \
	$(t_nlibs_lunpack_f_defs) $(t_nlibs_lunpack_f_inc) \
	#
t_img_r_m_stubs := \
	Not found java/lang/invoke/MethodHandle.invokeExact: ([Ljava/lang/Object;)Ljava/lang/Object; \
	Not found java/lang/invoke/MethodHandle.invoke: ([Ljava/lang/Object;)Ljava/lang/Object; \
	Not found java/lang/invoke/MethodHandle.invokeBasic: ([Ljava/lang/Object;)Ljava/lang/Object; \
	Not found java/lang/invoke/MethodHandle.linkToVirtual: ([Ljava/lang/Object;)Ljava/lang/Object; \
	Not found java/lang/invoke/MethodHandle.linkToStatic: ([Ljava/lang/Object;)Ljava/lang/Object; \
	Not found java/lang/invoke/MethodHandle.linkToSpecial: ([Ljava/lang/Object;)Ljava/lang/Object; \
	Not found java/lang/invoke/MethodHandle.linkToInterface: ([Ljava/lang/Object;)Ljava/lang/Object; \
	Not found java/lang/invoke/MethodHandleNatives.init: (Ljava/lang/invoke/MemberName;Ljava/lang/Object;)V \
	Not found java/lang/invoke/MethodHandleNatives.expand: (Ljava/lang/invoke/MemberName;)V \
	Not found java/lang/invoke/MethodHandleNatives.resolve: (Ljava/lang/invoke/MemberName;Ljava/lang/Class;)Ljava/lang/invoke/MemberName; \
	Not found java/lang/invoke/MethodHandleNatives.getMembers: (Ljava/lang/Class;Ljava/lang/String;Ljava/lang/String;ILjava/lang/Class;I[Ljava/lang/invoke/MemberName;)I \
	Not found java/lang/invoke/MethodHandleNatives.objectFieldOffset: (Ljava/lang/invoke/MemberName;)J \
	Not found java/lang/invoke/MethodHandleNatives.staticFieldOffset: (Ljava/lang/invoke/MemberName;)J \
	Not found java/lang/invoke/MethodHandleNatives.staticFieldBase: (Ljava/lang/invoke/MemberName;)Ljava/lang/Object; \
	Not found java/lang/invoke/MethodHandleNatives.getMemberVMInfo: (Ljava/lang/invoke/MemberName;)Ljava/lang/Object; \
	Not found java/lang/invoke/MethodHandleNatives.getConstant: (I)I \
	Not found java/lang/invoke/MethodHandleNatives.setCallSiteTargetNormal: (Ljava/lang/invoke/CallSite;Ljava/lang/invoke/MethodHandle;)V \
	Not found java/lang/invoke/MethodHandleNatives.setCallSiteTargetVolatile: (Ljava/lang/invoke/CallSite;Ljava/lang/invoke/MethodHandle;)V \
	Not found java/lang/invoke/MethodHandleNatives.registerNatives: ()V \
	Not found java/lang/invoke/MethodHandleNatives.getNamedCon: (I[Ljava/lang/Object;)I \
	Not found sun/invoke/anon/AnonymousClassLoader.loadClassInternal: (Ljava/lang/Class;[B[Ljava/lang/Object;)Ljava/lang/Class; \
	Not found sun/misc/Perf.attach: (Ljava/lang/String;II)Ljava/nio/ByteBuffer; \
	Not found sun/misc/Perf.detach: (Ljava/nio/ByteBuffer;)V \
	Not found sun/misc/Perf.createByteArray: (Ljava/lang/String;II[BI)Ljava/nio/ByteBuffer; \
	Not found sun/misc/Perf.highResCounter: ()J \
	Not found sun/misc/Perf.highResFrequency: ()J \
	Not found sun/misc/Unsafe.defineAnonymousClass: (Ljava/lang/Class;[B[Ljava/lang/Object;)Ljava/lang/Class; \
	Not found sun/misc/Unsafe.tryMonitorEnter: (Ljava/lang/Object;)Z \
	Not found sun/misc/Unsafe.getLoadAverage: ([DI)I \
	Not found sun/misc/Unsafe.loadFence: ()V \
	Not found sun/misc/Unsafe.storeFence: ()V \
	Not found sun/misc/Unsafe.fullFence: ()V \
	Not found sun/misc/Unsafe.reallocateMemory: (JJ)J \
	Not found sun/misc/Unsafe.shouldBeInitialized: (Ljava/lang/Class;)Z \
	#

ifneq ($(mf_target_win),t)
t_img_r_m_stubs += \
	Not found sun/nio/ch/Net.remotePort: (Ljava/io/FileDescriptor;)I \
	Not found sun/nio/ch/Net.remoteInetAddress: (Ljava/io/FileDescriptor;)Ljava/net/InetAddress; \
	#
endif

$(t_img_r_jar): $(JFILES) $(t_thincompat_jfilesbatch)
	@echo "Creating $(@F)..."
	@mkdir -p $(@D)
	@rm -f $(@)
	(cd $(modulesp) && \
		M=c && for D in */; do $(mf_default_jar) $${M}f0 $(@) -C $${D} .; M=u; done)

.PHONY: t_img_avn
t_img_avn:
	$(call avndomk,t_gen$(space)t_b2h$(space)t_nama)

$(t_img_r_h): $(t_img_r_jar)
	@echo "Generating $(@F)..."
	@mkdir -p $(@D)
	@rm -f $(@)
	@rm -f $(@).tmp
	$(call t_b2h_run,$(t_img_r_jar),myjdkjar,$(@).tmp)
	mv $(@).tmp $(@)

$(t_img_r_m): $(t_img_r_jar) $(t_img_r_m_src)
	@echo "Generating $(@F)..."
	@mkdir -p $(@D)
	@rm -f $(@)
	@rm -f $(@).tmp
	$(call t_nama_run,myjdkjni,$(t_img_r_jar),$(t_img_r_m_f),$(t_img_r_m_src),$(t_img_r_m_stubs)) > $(@).tmp
	mv $(@).tmp $(@)

$(eval $(call mf_echot,img,"Building t_img..."))

.PHONY: t_img
t_img: | t_emb $(call mf_echot_dep,img) $(t_img_r_jar) t_img_avn $(t_img_r_h) $(t_img_r_m) \
	;


#----------------------------------------


.PHONY: targets
targets: | \
	t_btools \
	t_nbtools \
	t_glocaled \
	t_gchard \
	t_gversion \
	t_gcharmap \
	t_gchardec \
	t_gbuffers \
	t_gexceptions \
	t_gprops \
	t_jcc \
	t_thincompat \
	t_gjavad \
	t_nlibs \
	t_emb \
	t_img \
	;

.PHONY: all
all: | $(mf_rootp)/makefile $(mf_outp) targets ;

.PHONY: f
f: | clean all ;

define HELP

endef
export HELP
.PHONY: help
help:
	@echo "$$HELP"

