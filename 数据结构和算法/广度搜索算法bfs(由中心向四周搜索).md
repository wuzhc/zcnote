## 参考
- https://www.cnblogs.com/nr-zhang/p/11236369.html
- https://blog.csdn.net/u010363932/article/details/82990966
- https://www.cnblogs.com/xbblogs/p/10104800.html

> 广度(宽度)算法用队列,目标是遍历所有节点

```go
package main

import (
	"fmt"
	"os"
)

type point struct {
	i, j int
}

//获取临近的点
func (p point) add(r point) point {
	return point{p.i + r.i, p.j + r.j}
}

//判断点是否在二维数组中，并返回点的值
func (p point) at(grid [][]int) (int, bool) {
	if p.i < 0 || p.i >= len(grid) {
		return 0, false
	}
	if p.j < 0 || p.j >= len(grid[p.i]) {
		return 0, false
	}
	return grid[p.i][p.j], true
}

//点的遍历顺序，左，下，右，上
var dirs = [4]point{
	{-1, 0}, {0, -1}, {1, 0}, {0, 1},
}

func walk(maze [][]int, start, end point) [][]int {
	steps := make([][]int, len(maze))

    // 二维切片需要再次make
	for i := range steps {
		steps[i] = make([]int, len(maze[i]))
	}

	Q := []point{start}

	for len(Q) > 0 {
		cur := Q[0]
		Q = Q[1:]

		if cur == end {
			break
		}

		for _, dir := range dirs {
			next := cur.add(dir)
			val, ok := next.at(maze)

			//next点在数组中，且不能为墙 ，next点不能是起点
			if !ok || val != 0 {
				continue
			}

			if next == start {
				continue
			}

			if steps[next.i][next.j] == 0 && next.i <= end.i && next.j <= end.j {
				curSteps, _ := cur.at(steps)
				steps[next.i][next.j] = curSteps + 1
				Q = append(Q, next)
			}
		}
	}

	return steps
}

func readMaze(fileName string) [][]int {
	file, _ := os.Open(fileName)
	defer file.Close()
	var row, col int
	fmt.Fscanf(file, "%d %d", &row, &col)

	maze := make([][]int, row)
	for i := range maze {
		maze[i] = make([]int, col)
		for j := range maze[i] {
			fmt.Fscan(file, &maze[i][j])
		}
	}
	return maze
}

func main() {
	maze := readMaze("arr.in")
	steps := walk(maze, point{0, 0}, point{len(maze) - 1, len(maze[0]) - 1})
	for _, row := range steps {
		for _, val := range row {
			fmt.Printf("%3d ", val)
		}
		fmt.Println()
	}
}

```

## Leetcode 994：腐烂的橘子
在给定的网格中，每个单元格可以有以下三个值之一：

值 0 代表空单元格；
值 1 代表新鲜橘子；
值 2 代表腐烂的橘子。
每分钟，任何与腐烂的橘子（在 4 个正方向上）相邻的新鲜橘子都会腐烂。

返回直到单元格中没有新鲜橘子为止所必须经过的最小分钟数。如果不可能，返回 -1。
![https://assets.leetcode.com/uploads/2019/02/16/oranges.png](https://assets.leetcode.com/uploads/2019/02/16/oranges.png)

示例 1：
```
输入：[[2,1,1],[1,1,0],[0,1,1]]
输出：4
```
示例 2：
```
输入：[[2,1,1],[0,1,1],[1,0,1]]
输出：-1
解释：左下角的橘子（第 2 行， 第 0 列）永远不会腐烂，因为腐烂只会发生在 4 个正向上。
```
示例 3：
```
输入：[[0,2]]
输出：0
解释：因为 0 分钟时已经没有新鲜橘子了，所以答案就是 0 。
```

## 思路
- 由中心向四周搜索为广度搜索bfs,可以使用队列来解决问题
- 起点是坏了橘子，即为2的单元格，将所有为2的单元格作为队列的初始值

## 解法
```golang
func orangesRotting(grid [][]int) int {
    if len(grid)==0 {
        return 0
    }

    var queue []Point
    for i,vv:=range grid {
        for j,v:=range vv {
            if v==2 {
                queue=append(queue,Point{i,j})
            }
        }
    }
   
    var res int = 0
    for len(queue)>0 {
        var tempQueue []Point
        for len(queue)>0 {
            node:=queue[0]
            queue=queue[1:]
            for _,dir:=range dirs {
                n:=node.Add(dir)
                if v,ok:=n.at(grid);ok && v==1 {
                    tempQueue=append(tempQueue,n)
                    grid[n.i][n.j] = 2
                } 
            }
        }

        // fmt.Println(tempQueue)
        res=res+1
        queue=append(queue,tempQueue...)
        // fmt.Println(queue,res)
    }

    for _,vv:=range grid {
        for _,v:=range vv {
            if v==1 {
                return -1
            }
        }
    }

    if res > 0 {
        return res - 1 
    } else {
        return res
    }
}

type Point struct {
    i,j int
}

func (p Point) Add(r Point) Point {
    return Point{p.i+r.i,p.j+r.j}
}

func (p Point) at(grid [][]int) (int, bool) {
    if p.i < 0 || p.i >= len(grid) {
        return 0,false
    } 
    if p.j < 0 || p.j >= len(grid[0]) {
        return 0,false
    }
    return grid[p.i][p.j],true
}

var dirs = [4]Point {
    {-1,0},{0,-1},{1,0},{0,1},
}
```


