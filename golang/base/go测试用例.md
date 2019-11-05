package main

import (
	"flag"
	"log"
	"net/http"
	_ "net/http/pprof"
	"os"
	"path/filepath"
	"sync"

	"github.com/judwhite/go-svc/svc"
	"github.com/wuzhc/gmq/internal/gnode"
)

// program implements svc.Service
type program struct {
	once sync.Once
	gn   *gnode.Gnode
}

func main() {
	prg := &program{}
	if err := svc.Run(prg); err != nil {
		log.Fatal(err)
	}
}

func (p *program) Init(env svc.Environment) error {
	if env.IsWindowsService() {
		dir := filepath.Dir(os.Args[0]) //获取路径最后一个斜杠前面部分路径即目录
		return os.Chdir(dir)            //改变当前工作目录
	}
	return nil
}

func (p *program) Start() error {
	p.gn = gnode.New()

	cfgFile := flag.String("config_file", "", "config file")
	flag.Parse()
	if len(*cfgFile) > 0 {
		p.gn.SetConfig(*cfgFile)
	}

	go func() {
		p.gn.Run()
	}()

	// pprof监控
	go func() {
		http.ListenAndServe("0.0.0.0:9512", nil)
	}()

	return nil
}

func (p *program) Stop() error {
	p.once.Do(func() {
		p.gn.Exit()
	})
	return nil
}
