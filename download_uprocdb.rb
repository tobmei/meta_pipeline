
#download and import pfam27 for uproc

url = "http://uproc.gobics.de/downloads/db/pfam27.uprocdb.gz"
`wget -P ./data #{url}`
puts 'decompressing ...'
`gzip -d ./data/pfam27.uprocdb.gz`
`mkdir ./data/pfam27_uproc`
`/work/gi/software/uproc-1.2.0/./uproc-import ./data/pfam27.uprocdb ./data/pfam27_uproc` 
puts 'delete pfam27.uprocdb'
`rm ./data/pfam27.uprocdb`