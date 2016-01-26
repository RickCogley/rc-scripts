cd /Users/rcogley/gdrive/Screenshots
cp "$1" .
echo "$1" > var.txt
# fn=`cat var.txt`
fn=$(basename "$1")
echo "$fn" >> var.txt
/Users/rcogley/gocode/bin/drive push --quiet "$fn"
/Users/rcogley/gocode/bin/drive pub "$fn"
/Users/rcogley/gocode/bin/drive url "$fn" | grep -o 'http*.*' | pbcopy
