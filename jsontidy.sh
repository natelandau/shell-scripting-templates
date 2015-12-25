#! /dev/null/bash

function jsontidy ()
{ python -c "import sys,json;print json.dumps(json.loads(sys.stdin.read()),ensure_ascii=1,sort_keys=1,indent=2,separators=(',',': '));sys.exit(0)"; }
