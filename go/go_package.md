# bytes
# bufio
```go
// NewReaderSize 将 rd 封装成一个拥有 size 大小缓存的 bufio.Reader 对象
func NewReaderSize(rd io.Reader, size int) *Reader
// NewReader 相当于 NewReaderSize(rd, 4096)
func NewReader(rd io.Reader) *Reader
// 返回缓存的一个切片，该切片引用缓存中前 n 字节数据
func (b *Reader) Peek(n int) ([]byte, error) 
// 从b读取数据到p中
func (b *Reader) Read(p []byte) (n int, err error)
// 从b读取一个字节到p中
func (b *Reader) ReadByte() (c byte, err error)
// 用 UnreadByte 撤消一个字节
func (b *Reader) UnreadByte() error
// 从b读取一个unicode字符
func (b *Reader) ReadRune() (r rune, size int, err error)
// 用UnreadRune 撤销一个字符
func (b *Reader) UnreadRune() error
// 返回缓存中数据的字节长度
func (b *Reader) Buffered() int 
// 返回b中的delim和delim之前的字节
func (b *Reader) ReadSlice(delim byte) (line []byte, err error)

// Flush 将缓存中的数据提交到底层的 io.Writer 中
func (b *Writer) Flush() error
// Available 返回缓存中的可以空间
func (b *Writer) Available() int
// Buffered 返回缓存中未提交的数据长度
func (b *Writer) Buffered() int
// 从r读取数据到b中，ReadFrom无需使用Flush，其自己已经写入．
func (b *Writer) ReadFrom(r io.Reader) (n int64, err error)
// WriteRune 向 b 中写入 r 的 UTF8 编码,需要调用 bw.Flush()写入到io.writer
func (b *Writer) WriteRune(r rune) (size int, err error)
// 丢弃没有写入到缓存的数据
func (b *Writer) Reset(w io.Writer)

// NewScanner 创建一个 Scanner 来扫描 r
func NewScanner(r io.Reader) *Scanner
// Split 用于设置 Scanner 的“切分函数”，例如bs.Split(bufio.ScanRunes)
func (s *Scanner) Split(split SplitFunc)
// 便获取错误信息
func (s *Scanner) Err() error
// Bytes 将最后一次扫描出的“指定部分”作为一个切片返回（引用传递）
func (s *Scanner) Bytes() []byte
//  Text 将最后一次扫描出的“指定部分”作为字符串返回（值传递）
func (s *Scanner) Text() string
// Scan 在 Scanner 的数据中扫描“指定部分”
func (s *Scanner) Scan() bool

```
# utf8
# strings
# io/ioutil
# errors
# sha1
# reflect