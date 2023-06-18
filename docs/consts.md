[Main](../../../) / [Usage](../../../#usage) / [Libraries](../../../#libraries) / [Installation](installation.md) / Description / [Coding](coding-standards.md) / [Configuration](../../../#configuration) / [Examples](../../../#examples) / [Tests](../../../#tests) / [Templates](../../../#templates) / [Docs](../../../#documentation)

## Description

### colors
Almost every bash script project has own color names standards:))
All available colors and formats are made available as constants that can be used in strings:
* `CLR_GOOD`
* `CLR_INFORM`
* `CLR_WARN`
* `CLR_BAD`
* `CLR_HILITE`
* `CLR_BRACKET`
* `CLR_NORMAL`
* `FMT_BOLD`
* `FMT_UNDERLINE`

### log levels
The same applies to the available log levels
* `LOG_LVL_OFF`
* `LOG_LVL_ERROR`
* `LOG_LVL_WARN`
* `LOG_LVL_INFORM`
* `LOG_LVL_DEBUG`

The current log level and whether a timestamp should be added to each entry can be configured:
```bash
LOG_LEVEL=${LOG_LVL_INFORM}
LOG_SHOW_TIMESTAMP=true
