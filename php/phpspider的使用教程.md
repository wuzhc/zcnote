```php
<?php

declare(strict_types = 1);

namespace App\Command;

use Hyperf\Command\Command as HyperfCommand;
use Hyperf\Command\Annotation\Command;
use phpspider\core\phpspider;
use phpspider\core\requests;
use Psr\Container\ContainerInterface;


/**
 * https://packagist.org/packages/jaeger/querylist
 * https://packagist.org/packages/vdb/php-spider
 * @Command
 */
class SpiderCommand extends HyperfCommand
{
    /**
     * @var ContainerInterface
     */
    protected $container;

    public function __construct(ContainerInterface $container)
    {
        $this->container = $container;

        parent::__construct('spider:run');
    }

    protected function getArguments()
    {
        return [// ['url', InputArgument::REQUIRED, '爬取的链接'],
        ];
    }

    public function configure()
    {
        parent::configure();
        $this->setDescription('爬虫');
    }

    public function handle()
    {
        global $argv;
        $argv[1] = 'start';

        // d($argv);
        $configs = [
            'name'               => '简书',
            'log_show'           => false,
            'tasknum'            => 1,//一个任务一个进程
            'log_file'           => './data/qiushibaike.log',
            'max_try'            => 5,

            //保存爬虫状态
            'save_running_state' => true,

            //代理
            // 'proxy' => array('http://user:pass@host:port'),//验证代理
            // 'proxy'=>array('http://host:port'),//普通代理

            //爬虫爬取每个网页的时间间隔,单位毫秒
            'interval'           => 3000,

            //爬取网页超时时间，单位秒
            'timeout'            => 5,

            //采集深度
            'max_depth'          => 5,

            //爬虫爬取网页所使用的浏览器类型
            // 'user_agent' => phpspider::AGENT_ANDROID,
            'user_agent'         => [
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36",
                "Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13G34 Safari/601.1",
                "Mozilla/5.0 (Linux; U; Android 6.0.1;zh_cn; Le X820 Build/FEXCNFN5801507014S) AppleWebKit/537.36 (KHTML, like Gecko)Version/4.0 Chrome/49.0.0.0 Mobile Safari/537.36 EUI Browser/5.8.015S",
            ],

            //随机伪造IP，用于破解防采集
            'client_ip'          => [
                '192.168.0.2',
                '192.168.0.3',
                '192.168.0.4',
            ],

            'queue_config'        => [
                'host'    => '127.0.0.1',
                'port'    => 6379,
                'pass'    => '',
                'db'      => 5,
                'prefix'  => 'phpspider',
                'timeout' => 30,
            ],

            //数据库配置
            'db_config'           => [
                'host' => '127.0.0.1',
                'port' => 3306,
                'user' => 'root',
                'pass' => '123456',
                'name' => 'runcode',
            ],

            //导出数据，支持sql,csv,db
            'export'              => [
                'type' => 'csv',
                'file' => '/data/qiushibaike.csv',
            ],

            //定义爬虫爬取哪些域名下的网页, 非域名下的url会被忽略以提高爬取速度
            'domains'             => [
                'jianshu',
                'www.jianshu.com'
            ],

            //抓取的起点
            'scan_urls'           => [
                'https://www.jianshu.com/c/V2CqjW?utm_medium=index-collections&utm_source=desktop'
            ],

            //列表页实例
            'list_url_regexes'    => [
                "https://www.jianshu.com/c/\d+"
            ],

            //内容页实例
            //  \d+  指的是变量
            'content_url_regexes' => [
                "https://www.jianshu.com/p/\d+",
            ],


            // 'fields' => [
            //     [
            //         'name'     => "title",
            //         'selector' => "//h1[@class='title']",
            //         'required' => true,
            //     ],
            //     [
            //         'name'     => "content",
            //         'selector' => "//div[@class='show-content-free']",
            //         'required' => true,
            //     ],

            //selector_type指定正则
            // [
            // 'name'          => 'title',
            // 'selector_type' => 'regex', //使用正则表达式
            // 'selector'      => '#<div\sclass="content">([^/]+)</div>#i' // regex抽取规则
            // ],

            //children子项
            // [
            //     'name'     => "article_comments",
            //     'selector' => "//div[contains(@class,'comments-wrap')]",
            //     'children' => [
            //         [
            //             'name'     => "replay",
            //             'selector' => "//div[contains(@class,'replay')]",
            //             'repeated' => true,
            //         ],
            //         [
            //             'name'     => "report",
            //             'selector' => "//div[contains(@class,'report')]",
            //             'repeated' => true,
            //         ]
            //     ]
            // ],

            //attached_url重新发起请求
            // [
            //     'name'          => "comments",
            //     'source_type'   => 'attached_url',
            //// "comments"是从发送"attached_url"这个异步请求返回的数据中抽取的
            //// "attachedUrl"支持引用上下文中的抓取到的"field", 这里就引用了上面抓取的"comment_id"
            // 'attached_url'  => "https://www.zhihu.com/r/answers/{comment_id}/comments",
            // 'selector_type' => 'jsonpath',
            // 'selector'      => "$.data",
            // 'repeated'      => true,
            // 'children'      => [],
            // ]


            // ],
        ];

        $spider = new phpspider($configs);
        $spider->on_start = function ($phpspider) {
            requests::set_referer("http://www.qiushibaike.com"); //设置请求来路URL
            requests::set_cookie("BAIDUID", "FEE96299191CB0F11954F3A0060FB470:FG=1");//设置cookie
            requests::set_cookies("BAIDUID=FEE96299191CB0F11954F3A0060FB470:FG=1; BIDUPSID=FEE96299191CB0F11954F3A0060FB470;");
        };

        //爬取页面是返回的状态
        $spider->on_status_code = function ($status_code, $url, $content, $phpspider) {
            // 如果状态码为429，说明对方网站设置了不让同一个客户端同时请求太多次
            if ($status_code == '429') {
                // 将url插入待爬的队列中,等待再次爬取
                $phpspider->add_url($url);
                // 当前页先不处理了
                return false;
            }
            // 不拦截的状态码这里记得要返回，否则后面内容就都空了
            return $content;
        };

        //当前网页是否被反爬虫了
        $spider->is_anti_spider = function ($url, $content, $phpspider) {
            // $content中包含"404页面不存在"字符串
            if (strpos($content, "404页面不存在") !== false) {
                // 如果使用了代理IP，IP切换需要时间，这里可以添加到队列等下次换了IP再抓取
                // $phpspider->add_url($url);
                return true; // 告诉框架网页被反爬虫了，不要继续处理它
            }
            // 当前页面没有被反爬虫，可以继续处理
            return false;
        };

        //网页下载后回调
        $spider->on_download_page = function($page, $phpspider)
        {
            $page_html = "<div id=\"comment-pages\"><span>5</span></div>";
            $index = strpos($page['row'], "</body>");
            $page['raw'] = substr($page['raw'], 0, $index) . $page_html . substr($page['raw'], $index);
            return $page;
        };

        //在一个网页获取到URL之后调用. 主要用来对获取到的URL进行处理.
        $spider->on_fetch_url = function($url, $phpspider)
        {
            //如果获取到URL包含#filter，不入URL采集队列
            if (strpos($url, "#filter") !== false)
            {
                return false;
            }
            return $url;
        };

        $spider->start();
    }
}
```