测试用例方法名`func TestXxx(t *testing.T)`使用的方法包括`Error`、`Errorf`、`FailNow`、`Fatal`、`FatalIf`,调用`Log`方法来记录测试信息

压力测试方法名`func BenchmarkXXX(b *testing.B)`,默认情况下`get test`不会执行压力测试,需要加上`-test.bench`,例如`go test -test.bench`

```bash
func TestIntArray_Shift(t *testing.T) {
	arr := NewIntArray()
	arr.Push(1, 2, 3)
	res := arr.Shift()
	if res == 1 {
		t.Log("pass")
	} else {
		t.Errorf(fmt.Sprintf("expect:1, result:%d", res))
	}
}


```