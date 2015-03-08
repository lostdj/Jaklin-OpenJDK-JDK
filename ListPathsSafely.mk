compress_pre:=$(strip $(shell cat $(mf_rootp)/../make/common/support/ListPathsSafely-pre-compress.incl))
compress_post:=$(strip $(shell cat $(mf_rootp)/../make/common/support/ListPathsSafely-post-compress.incl))
compress_paths=$(compress_pre)\
$(subst $(shell realpath -m $(mf_rootp)/..),X97,\
$(subst $(buildp),X98,\
$(subst X,X00,\
$(subst $(space),\n,$(strip $1)))))\
$(compress_post) 

decompress_paths=sed -f $(mf_rootp)/../make/common/support/ListPathsSafely-uncompress.sed -e 's|X99|\\n|g' \
    -e 's|X98|'$(buildp)'|g' -e 's|X97|'$$(realpath -m $(mf_rootp)/..)'|g' \
    -e 's|X00|X|g' | tr '\n' '$2'

define ListPathsSafely_If
	$(if $(word $3,$($1)),$(eval $1_LPS$3:=$(call compress_paths,$(wordlist $3,$4,$($1)))))
endef

EscapeDollar = $(subst $$,\$$,$(subst \$$,$$,$(strip $1)))

define ListPathsSafely_Printf
	$(if $(strip $($1_LPS$4)),$(if $(findstring ,trace),,@)printf \
	    -- "$(strip $(call EscapeDollar, $($1_LPS$4)))\n" | $(decompress_paths) $3)
endef

# Receipt example:
#   rm -f thepaths
#   $(call ListPathsSafely,THEPATHS,\n, >> thepaths)
# The \n argument means translate spaces into \n
# if instead , , (a space) is supplied, then spaces remain spaces.
define ListPathsSafely
	$(if $(word 16001,$($1)),$(error Cannot list safely more than 16000 paths. $1 has $(words $($1)) paths!))
	@echo Writing $(words $($1)) paths to '$3'
	$(call ListPathsSafely_If,$1,$2,1,250)
	$(call ListPathsSafely_If,$1,$2,251,500)
	$(call ListPathsSafely_If,$1,$2,501,750)
	$(call ListPathsSafely_If,$1,$2,751,1000)

	$(call ListPathsSafely_If,$1,$2,1001,1250)
	$(call ListPathsSafely_If,$1,$2,1251,1500)
	$(call ListPathsSafely_If,$1,$2,1501,1750)
	$(call ListPathsSafely_If,$1,$2,1751,2000)

	$(call ListPathsSafely_If,$1,$2,2001,2250)
	$(call ListPathsSafely_If,$1,$2,2251,2500)
	$(call ListPathsSafely_If,$1,$2,2501,2750)
	$(call ListPathsSafely_If,$1,$2,2751,3000)

	$(call ListPathsSafely_If,$1,$2,3001,3250)
	$(call ListPathsSafely_If,$1,$2,3251,3500)
	$(call ListPathsSafely_If,$1,$2,3501,3750)
	$(call ListPathsSafely_If,$1,$2,3751,4000)

	$(call ListPathsSafely_If,$1,$2,4001,4250)
	$(call ListPathsSafely_If,$1,$2,4251,4500)
	$(call ListPathsSafely_If,$1,$2,4501,4750)
	$(call ListPathsSafely_If,$1,$2,4751,5000)

	$(call ListPathsSafely_If,$1,$2,5001,5250)
	$(call ListPathsSafely_If,$1,$2,5251,5500)
	$(call ListPathsSafely_If,$1,$2,5501,5750)
	$(call ListPathsSafely_If,$1,$2,5751,6000)

	$(call ListPathsSafely_If,$1,$2,6001,6250)
	$(call ListPathsSafely_If,$1,$2,6251,6500)
	$(call ListPathsSafely_If,$1,$2,6501,6750)
	$(call ListPathsSafely_If,$1,$2,6751,7000)

	$(call ListPathsSafely_If,$1,$2,7001,7250)
	$(call ListPathsSafely_If,$1,$2,7251,7500)
	$(call ListPathsSafely_If,$1,$2,7501,7750)
	$(call ListPathsSafely_If,$1,$2,7751,8000)

	$(call ListPathsSafely_If,$1,$2,8001,8250)
	$(call ListPathsSafely_If,$1,$2,8251,8500)
	$(call ListPathsSafely_If,$1,$2,8501,8750)
	$(call ListPathsSafely_If,$1,$2,8751,9000)

	$(call ListPathsSafely_If,$1,$2,9001,9250)
	$(call ListPathsSafely_If,$1,$2,9251,9500)
	$(call ListPathsSafely_If,$1,$2,9501,9750)
	$(call ListPathsSafely_If,$1,$2,9751,10000)

	$(call ListPathsSafely_If,$1,$2,10001,10250)
	$(call ListPathsSafely_If,$1,$2,10251,10500)
	$(call ListPathsSafely_If,$1,$2,10501,10750)
	$(call ListPathsSafely_If,$1,$2,10751,11000)

	$(call ListPathsSafely_If,$1,$2,11001,11250)
	$(call ListPathsSafely_If,$1,$2,11251,11500)
	$(call ListPathsSafely_If,$1,$2,11501,11750)
	$(call ListPathsSafely_If,$1,$2,11751,12000)

	$(call ListPathsSafely_If,$1,$2,12001,12250)
	$(call ListPathsSafely_If,$1,$2,12251,12500)
	$(call ListPathsSafely_If,$1,$2,12501,12750)
	$(call ListPathsSafely_If,$1,$2,12751,13000)

	$(call ListPathsSafely_If,$1,$2,13001,13250)
	$(call ListPathsSafely_If,$1,$2,13251,13500)
	$(call ListPathsSafely_If,$1,$2,13501,13750)
	$(call ListPathsSafely_If,$1,$2,13751,14000)

	$(call ListPathsSafely_If,$1,$2,14001,14250)
	$(call ListPathsSafely_If,$1,$2,14251,14500)
	$(call ListPathsSafely_If,$1,$2,14501,14750)
	$(call ListPathsSafely_If,$1,$2,14751,15000)

	$(call ListPathsSafely_If,$1,$2,15001,15250)
	$(call ListPathsSafely_If,$1,$2,15251,15500)
	$(call ListPathsSafely_If,$1,$2,15501,15750)
	$(call ListPathsSafely_If,$1,$2,15751,16000)

	$(call ListPathsSafely_Printf,$1,$2,$3,1)
	$(call ListPathsSafely_Printf,$1,$2,$3,251)
	$(call ListPathsSafely_Printf,$1,$2,$3,501)
	$(call ListPathsSafely_Printf,$1,$2,$3,751)

	$(call ListPathsSafely_Printf,$1,$2,$3,1001)
	$(call ListPathsSafely_Printf,$1,$2,$3,1251)
	$(call ListPathsSafely_Printf,$1,$2,$3,1501)
	$(call ListPathsSafely_Printf,$1,$2,$3,1751)

	$(call ListPathsSafely_Printf,$1,$2,$3,2001)
	$(call ListPathsSafely_Printf,$1,$2,$3,2251)
	$(call ListPathsSafely_Printf,$1,$2,$3,2501)
	$(call ListPathsSafely_Printf,$1,$2,$3,2751)

	$(call ListPathsSafely_Printf,$1,$2,$3,3001)
	$(call ListPathsSafely_Printf,$1,$2,$3,3251)
	$(call ListPathsSafely_Printf,$1,$2,$3,3501)
	$(call ListPathsSafely_Printf,$1,$2,$3,3751)

	$(call ListPathsSafely_Printf,$1,$2,$3,4001)
	$(call ListPathsSafely_Printf,$1,$2,$3,4251)
	$(call ListPathsSafely_Printf,$1,$2,$3,4501)
	$(call ListPathsSafely_Printf,$1,$2,$3,4751)

	$(call ListPathsSafely_Printf,$1,$2,$3,5001)
	$(call ListPathsSafely_Printf,$1,$2,$3,5251)
	$(call ListPathsSafely_Printf,$1,$2,$3,5501)
	$(call ListPathsSafely_Printf,$1,$2,$3,5751)

	$(call ListPathsSafely_Printf,$1,$2,$3,6001)
	$(call ListPathsSafely_Printf,$1,$2,$3,6251)
	$(call ListPathsSafely_Printf,$1,$2,$3,6501)
	$(call ListPathsSafely_Printf,$1,$2,$3,6751)

	$(call ListPathsSafely_Printf,$1,$2,$3,7001)
	$(call ListPathsSafely_Printf,$1,$2,$3,7251)
	$(call ListPathsSafely_Printf,$1,$2,$3,7501)
	$(call ListPathsSafely_Printf,$1,$2,$3,7751)

	$(call ListPathsSafely_Printf,$1,$2,$3,8001)
	$(call ListPathsSafely_Printf,$1,$2,$3,8251)
	$(call ListPathsSafely_Printf,$1,$2,$3,8501)
	$(call ListPathsSafely_Printf,$1,$2,$3,8751)

	$(call ListPathsSafely_Printf,$1,$2,$3,9001)
	$(call ListPathsSafely_Printf,$1,$2,$3,9251)
	$(call ListPathsSafely_Printf,$1,$2,$3,9501)
	$(call ListPathsSafely_Printf,$1,$2,$3,9751)

	$(call ListPathsSafely_Printf,$1,$2,$3,10001)
	$(call ListPathsSafely_Printf,$1,$2,$3,10251)
	$(call ListPathsSafely_Printf,$1,$2,$3,10501)
	$(call ListPathsSafely_Printf,$1,$2,$3,10751)

	$(call ListPathsSafely_Printf,$1,$2,$3,11001)
	$(call ListPathsSafely_Printf,$1,$2,$3,11251)
	$(call ListPathsSafely_Printf,$1,$2,$3,11501)
	$(call ListPathsSafely_Printf,$1,$2,$3,11751)

	$(call ListPathsSafely_Printf,$1,$2,$3,12001)
	$(call ListPathsSafely_Printf,$1,$2,$3,12251)
	$(call ListPathsSafely_Printf,$1,$2,$3,12501)
	$(call ListPathsSafely_Printf,$1,$2,$3,12751)

	$(call ListPathsSafely_Printf,$1,$2,$3,13001)
	$(call ListPathsSafely_Printf,$1,$2,$3,13251)
	$(call ListPathsSafely_Printf,$1,$2,$3,13501)
	$(call ListPathsSafely_Printf,$1,$2,$3,13751)

	$(call ListPathsSafely_Printf,$1,$2,$3,14001)
	$(call ListPathsSafely_Printf,$1,$2,$3,14251)
	$(call ListPathsSafely_Printf,$1,$2,$3,14501)
	$(call ListPathsSafely_Printf,$1,$2,$3,14751)

	$(call ListPathsSafely_Printf,$1,$2,$3,15001)
	$(call ListPathsSafely_Printf,$1,$2,$3,15251)
	$(call ListPathsSafely_Printf,$1,$2,$3,15501)
	$(call ListPathsSafely_Printf,$1,$2,$3,15751)
endef

define ListPathsSafelyNow_IfPrintf
  ifneq (,$$(word $4,$$($1)))
    $$(eval $1_LPS$4:=$$(call compress_paths,$$(wordlist $4,$5,$$($1))))
    $$(shell printf -- "$$(strip $$($1_LPS$4))\n" | $(decompress_paths) $3)
  endif
endef

# And an non-receipt version:
define ListPathsSafelyNow
  ifneq (,$$(word 10001,$$($1)))
    $$(error Cannot list safely more than 10000 paths. $1 has $$(words $$($1)) paths!)
  endif
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,1,250)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,251,500)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,501,750)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,751,1000)

  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,1001,1250)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,1251,1500)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,1501,1750)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,1751,2000)

  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,2001,2250)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,2251,2500)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,2501,2750)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,2751,3000)

  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,3001,3250)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,3251,3500)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,3501,3750)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,3751,4000)

  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,4001,4250)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,4251,4500)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,4501,4750)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,4751,5000)

  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,5001,5250)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,5251,5500)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,5501,5750)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,5751,6000)

  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,6001,6250)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,6251,6500)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,6501,6750)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,6751,7000)

  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,7001,7250)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,7251,7500)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,7501,7750)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,7751,8000)

  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,8001,8250)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,8251,8500)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,8501,8750)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,8751,9000)

  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,9001,9250)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,9251,9500)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,9501,9750)
  $(call ListPathsSafelyNow_IfPrintf,$1,$2,$3,9751,10000)

endef

