# ION Core Feature List

**Last Update:** 2025-11-11

## **ION Core Version:** 4.1.4-b.1

Based on ION-DTN version 4.1.4-b.1.

## Status Legend

- **y** = included mandatory
- **c** = included optional build
- **p** = planned (will be released in next version)
- **w** = requested (requested for inclusion in future TBD version)

## [ION Core Feature List](#ion-core-feature-list)
- [ION Core Feature List](#ion-core-feature-list)
  - [**ION Core Version:** 4.1.4-b.1](#ion-core-version-414-b1)
  - [Status Legend](#status-legend)
  - [ION Core Feature List](#ion-core-feature-list-1)
  - [ici](#ici)
  - [ici - utility](#ici---utility)
  - [bpv7](#bpv7)
  - [bpextensions - all part of bpv7](#bpextensions---all-part-of-bpv7)
  - [bpv7 - ipn](#bpv7---ipn)
  - [bpv7 - ipnd](#bpv7---ipnd)
  - [bpv7 - bibe](#bpv7---bibe)
  - [bpv7 - bpsec](#bpv7---bpsec)
  - [bpv7 - brs](#bpv7---brs)
  - [bpv7 - load and go](#bpv7---load-and-go)
  - [ams](#ams)
  - [bss](#bss)
  - [bpv7 - bssp - deprecated](#bpv7---bssp---deprecated)
  - [bpv6 - bssp - legacy, no plan for inclusion in the future](#bpv6---bssp---legacy-no-plan-for-inclusion-in-the-future)
  - [bpv7 - stcp](#bpv7---stcp)
  - [bpv7 - tcp](#bpv7---tcp)
  - [bpv7 - udp](#bpv7---udp)
  - [cfdp](#cfdp)
  - [bpv7 - cgr](#bpv7---cgr)
  - [bpv7 - cpsd](#bpv7---cpsd)
  - [bpv7 - dccp](#bpv7---dccp)
  - [dgr](#dgr)
  - [dtpc](#dtpc)
  - [bpv7 - imc](#bpv7---imc)
  - [tc - dtka](#tc---dtka)
  - [bpv7 - dtn2](#bpv7---dtn2)
  - [ltp](#ltp)
  - [mn](#mn)
  - [restart](#restart)
  - [tc](#tc)
  - [manpages](#manpages)
  - [utilities](#utilities)
  - [Platform Port Examples](#platform-port-examples)
  - [External Contributions](#external-contributions)
  - [bench tests](#bench-tests)
  - [regression tests](#regression-tests)
  - [Notes for Version 4.1.4-b.1](#notes-for-version-414-b1)
  - [Build Configuration](#build-configuration)
    - [Extension Block Build Options](#extension-block-build-options)
    - [Convergence Layer Adapters (CLAs)](#convergence-layer-adapters-clas)
  - [References](#references)


---

## ici

| Status | Executable/Library |
|--------|-------------------|
| y | ionadmin |
| y | ionwarn |
| y | rfxclock |
| y | ionrestart |
| y | ionstart |
| y | ionstart.awk |
| y | ionstop |
| y | killm |
| | file2sdr |
| | file2sm |
| | ionexit |
| | ionlog |
| | ionunlock |
| | ionxnowner |
| p | ionsecadmin |

## ici - utility

| Status | Executable/Library |
|--------|-------------------|
| | psmshell |
| c | psmwatch |
| | sdr2file |
| | sdrmend |
| c | sdrwatch |
| | sm2file |
| | smlistsh |
| | smrbtsh |
| | tcp2file |
| | udp2file |

## bpv7

| Status | Executable/Library |
|--------|-------------------|
| y | bpadmin |
| y | bpclm |
| y | bpclock |
| y | bptransit |
| c | bpversion |

## bpextensions - all part of bpv7

| Status | Executable/Library | Notes |
|--------|-------------------|-------|
| y | bpq (bundle protocol qos) | Enabled by default for locally sourced bundles |
| y | imc (bundle multicast) | Enabled by default for locally sourced bundles |
| c | pbn (previous node) | Configurable via EXT_FLAGS in build-list.mk |
| c | bae (bundle age) | Configurable via EXT_FLAGS in build-list.mk |
| c | snw (spray and wait) | Configurable via EXT_FLAGS in build-list.mk |
| y | qos (quality of service) | Always supported for processing |
| y | meb (metadata) | Always supported for processing |
| y | hcb (hop count) | Always supported for processing |
| y | bib (bundle integrity) | Always supported for processing |
| y | bcb (bundle confidentiality) | Always supported for processing |
| | cgrr (cgr route extension) | |
| | rgr (register route extension) | |

## bpv7 - ipn

| Status | Executable/Library |
|--------|-------------------|
| y | ipnadmin |
| y | ipnadminep |
| y | ipnfw |

## bpv7 - ipnd

| Status | Executable/Library |
|--------|-------------------|
| | ipnd |

## bpv7 - bibe

| Status | Executable/Library |
|--------|-------------------|
| | bibeadmin |
| | bibeclo |

## bpv7 - bpsec

| Status | Executable/Library |
|--------|-------------------|
| p | bpsecadmin |

## bpv7 - brs

| Status | Executable/Library |
|--------|-------------------|
| | brsccla |
| | brsscla |

## bpv7 - load and go

| Status | Executable/Library |
|--------|-------------------|
| c | lgagent |
| c | lgsend |

## ams

| Status | Executable/Library |
|--------|-------------------|
| | amsmib |
| | amsshell |
| | amsstop |
| | ramsgate |

## bss

| Status | Executable/Library |
|--------|-------------------|
| p | bsscounter |
| p | bssdriver |
| p | bssrecv |
| p | bssStreamingApp |

## bpv7 - bssp - deprecated

| Status | Executable/Library |
|--------|-------------------|
| | bsspadmin |
| | bsspcli |
| | bsspclo |
| | bsspclock |
| | udpbso |
| | udpbsi |
| | tcpbso |
| | tcpbsi |

## bpv6 - bssp - legacy, no plan for inclusion in the future

| Status | Executable/Library |
|--------|-------------------|
| | bsspadmin |
| | bsspcli |
| | bsspclo |
| | bsspclock |
| | udpbso |
| | udpbsi |
| | tcpbso |
| | tcpbsi |

## bpv7 - stcp

| Status | Executable/Library |
|--------|-------------------|
| c | stcpcli |
| c | stcpclo |

## bpv7 - tcp

| Status | Executable/Library |
|--------|-------------------|
| p | tcpbsi |
| p | tcpsbo |

## bpv7 - udp

| Status | Executable/Library |
|--------|-------------------|
| c | udpcli |
| c | udpclo |

## cfdp

| Status | Executable/Library |
|--------|-------------------|
| c | bputa |
| c | cfdpadmin |
| c | cfdpclock |
| c | cfdptest |
| c | tcputa |

## bpv7 - cgr

| Status | Executable/Library |
|--------|-------------------|
| | cgrfetch |

## bpv7 - cpsd

| Status | Executable/Library |
|--------|-------------------|
| | cpsd |

## bpv7 - dccp

| Status | Executable/Library |
|--------|-------------------|
| | dccpcli |
| | dccpclo |
| | dccplsi |
| | dccplso |

## dgr

| Status | Executable/Library |
|--------|-------------------|
| | dgr2file |
| | dgrcli |
| | dgrclo |
| | file2dgr |

## dtpc

| Status | Executable/Library |
|--------|-------------------|
| | dtpcadmin |
| | dtpcclock |
| | dtpcd |
| | dtpcreceive |
| | dtpcsend |

## bpv7 - imc

| Status | Executable/Library |
|--------|-------------------|
| y | libimcfw |
| | imcadmin |
| | imcadminep |
| | imcfw |

## tc - dtka

| Status | Executable/Library |
|--------|-------------------|
| | dtka |
| | dtkaadmin |

## bpv7 - dtn2

| Status | Executable/Library |
|--------|-------------------|
| | dtn2admin |
| | dtn2adminep |
| | dtn2fw |

## ltp

| Status | Executable/Library |
|--------|-------------------|
| c | ltpcli |
| c | ltpclo |
| c | ltpclock |
| c | ltpdeliv |
| c | ltpmeter |
| c | udplsi |
| c | udplso |
| c | ltpadmin |
| c | sdatest |
| c | ltpcounter |
| c | ltpdriver |
| c | ltpsecadmin |

## mn

| Status | Executable/Library |
|--------|-------------------|
| | nm_agent |
| | nm_mgr |

## restart

| Status | Executable/Library |
|--------|-------------------|
| y | ionrestart |

## tc

| Status | Executable/Library |
|--------|-------------------|
| | tcaddmin |
| | tcaboot |
| | tcacompile |
| | tcapublish |
| | tcarecv |
| | tcc |
| | tccadmin |

## manpages

| Status | Executable/Library |
|--------|-------------------|
| c | |

## utilities

| Status | Executable/Library |
|--------|-------------------|
| c | bprecvfile |
| c | bpsendfile |
| | bprecvfile2 |
| y | bpsink |
| y | bpsource |
| c | bpcancel |
| c | bpchat |
| c | bpcounter |
| c | bpcp |
| c | bpcpd |
| | bpcrash |
| c | bpdriver |
| y | bpecho |
| y | bping |
| c | bplist |
| | bpnmtest |
| y | bpstats |
| | bpstats2 |
| y | bptrace |
| c | owltsim |
| | secure_bpsendfile |
| | secure_bprecvfile |

## Platform Port Examples

| Status | Executable/Library |
|--------|-------------------|
| | arch-android |
| | arch-rtems |
| | arch-uClibc |

## External Contributions

| Status | Executable/Library |
|--------|-------------------|
| | bptap |
| | dtnperf |
| | dtnsuite |
| | F prime integration prototype |

## bench tests

| Status | Executable/Library |
|--------|-------------------|
| c | bench-ltp |
| c | bench-udp |
| c | bench-stcp |
| c | bench-cfdp |

## regression tests

| Status | Executable/Library |
|--------|-------------------|
| c | demos/bench-udp |
| c | demos/bench-ltp |
| c | demos/bench-stcp |
| c | demos/bench-cfdp |
| c | tests/bptrace_terminal_test |
| c | tests/bping |
| c | tests/issue-352-bpcp-ltp |
| c | tests/issue-352-bpcp-stcp |

---

## Notes for Version 4.1.4-b.1

This feature list is based on ION Core 4.1.3s and updated for 4.1.4-b.1. The following changes are anticipated for 4.1.4-b.1:

1. **New source files and APIs** - ION-DTN 4.1.4-b.1 includes new source files and public APIs (details TBD)
2. **BPSec support** - bpsecadmin is planned (p = planned) for 4.1.5
3. **ION-Core-specific modifications** - Only `bpextensions.c` requires conditional compilation changes for ION-CORE-BUILD flag
4. **Submodule architecture** - This version uses ION-DTN as a git submodule pointing to tag `ion-open-source-4.1.4-b.1`

---

## Build Configuration

Features can be selected/excluded via the `build-list.mk` (Makefile) or `build-list.cmake` (CMake) files.

### Extension Block Build Options

Extension blocks can be categorized into three groups:

1. **Enabled by default for locally sourced bundles** (in build-list.mk):
   - **BPQ_EXT** - Bundle Protocol QoS Extension Block
   - **IMC_EXT** - IMC Multicast Extension Block

2. **Configurable via EXT_FLAGS** (commented out by default in build-list.mk):
   - **PNB_EXT** - Previous Node Extension Block
   - **BAE_EXT** - Bundle Age Extension Block
   - **SNW_EXT** - Spray and Wait Permit Extension Block

3. **Always supported for processing** (regardless of build configuration):
   - QOS (Quality of Service), MEB (Metadata), HCB (Hop Count), BIB (Bundle Integrity), BCB (Bundle Confidentiality)

To enable additional extension blocks for locally sourced bundles, uncomment the corresponding lines in build-list.mk (lines 69-73).

### Convergence Layer Adapters (CLAs)

At least one CLA must be selected for build:

- **LTP** - Licklider Transmission Protocol (c = included optional build)
- **UDP** - User Datagram Protocol (c = included optional build)
- **STCP** - Simple TCP (c = included optional build)
- **TCP** - Transmission Control Protocol (w = planned)

---

## References

- ION-DTN Repository: https://github.com/nasa-jpl/ION-DTN
- ION-Core Repository: https://github.com/nasa-jpl/ion-core-dev
- Documentation: See [docs/SUBMODULE-WORKFLOW.md](docs/SUBMODULE-WORKFLOW.md)
