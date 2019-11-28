## 名词
- 角色
- 权限
- 规则
- 用户
- 角色是权限的集合
- 一个角色 可以指派给一个或者多个用户
- 检查用户是否有权限,其实就是检查对应角色是否有权限
- 角色和权限按层次组织,即父子级

## 表设计
- tbItemTable： 该表存放授权条目,即角色和权限
- tbItemChildTable： 该表存放授权条目的层次关系,即角色和权限父子级关系
- tbAssignmentTable： 该表存放授权条目对用户的指派情况。
- tbRuleTable： 该表存放规则。

授权项目
做一件事的许可,可分为操作,任务,角色,角色包括多个任务,任务包括多个操作,一个操作就是一个许可,举例说明:
例如，我们有一个系统，它有一个 管理员 角色，它由 帖子管理 和 用户管理 任务组成。 用户管理 任务可以包含 创建用户，修改用户 和 删除用户 操作组成

```php
// yii1.1版本
if(Yii::app()->user->checkAccess('deletePost'))
{
    // 删除此帖
}
```

## 过程
- 定义授权(`CAuthManager::createRole`,`CAuthManager::createTask`,`CAuthManager::createOperation`)
- 创建授权项目之间的关系(`CAuthManager::addItemChild`,`CAuthManager::removeItemChild`,`CAuthItem::addChild`,`CAuthItem::removeChild`)
- 分配给角色(`CAuthManager::assign`,`CAuthManager::revoke`)

## 默认角色
`CAuthManager::defaultRoles`


public function actionR()
    {
        if(Yii::app()->user->checkAccess('createPost'))
        {
            echo 'create post';
        } else {
            echo 'no';
        }
    }

    public function actionT()
    {
        // /** @var CDbAuthManager $auth */
        $auth=Yii::app()->authManager;

        $auth->createOperation('createPost','create a post');
        $auth->createOperation('readPost','read a post');
        $auth->createOperation('updatePost','update a post');
        $auth->createOperation('deletePost','delete a post');
        
        $bizRule='return Yii::app()->user->id==$params["post"]->authID;';
        $task=$auth->createTask('updateOwnPost','update a post by author himself',$bizRule);
        $task->addChild('updatePost');
        
        $role=$auth->createRole('reader');
        $role->addChild('readPost');
        
        $role=$auth->createRole('author');
        $role->addChild('reader');
        $role->addChild('createPost');
        $role->addChild('updateOwnPost');
        
        $role=$auth->createRole('editor');
        $role->addChild('reader');
        $role->addChild('updatePost');
        
        $role=$auth->createRole('admin');
        $role->addChild('editor');
        $role->addChild('author');
        $role->addChild('deletePost');
        
        $auth->assign('reader','readerA');
        $auth->assign('author','authorB');
        $auth->assign('deletePost','125900');
        $auth->assign('editor','editorC');
        $auth->assign('admin','adminD');

        $bizRule='return !Yii::app()->user->isGuest;';
        $auth->createRole('authenticated', 'authenticated user', $bizRule);

        $bizRule='return Yii::app()->user->isGuest;';
        $auth->createRole('guest', 'guest user', $bizRule);
    }
    
    
    
    
    
    
    
    <?php
// /**
//  * Created by PhpStorm.
//  * User: wuzhc
//  * Date: 19-11-19
//  * Time: 下午2:21
//  */
//
// $path = './protected';
// $files = scandir($path);
// $route = [];
// foreach ($files as $file) {
//     if ($file == '.' || $file == '..') {
//         continue;
//     }
//     if (is_dir($file)) {
//         if ($file!='module' || $file!='controllers') {
//             continue;
//         }
//     }
//
//     // controller
//     if (!preg_match('/(\w+)Controller.php/', $file, $match)) {
//         continue;
//     }
//     $controllerName = lcfirst($match[1]);
//
//     // action
//     $p = $path . '/' . $file;
//     $content = file_get_contents($p);
//     preg_match_all('/public function action(\w+)/', $content, $matches, PREG_PATTERN_ORDER);
//     if (!$matches) {
//         continue;
//     }
//     foreach ($matches[1] as $m) {
//         $actionName = lcfirst($m);
//         $route[] = sprintf('%s.%s.%s', 'teachingV3', $controllerName, $actionName);
//     }
// }
//
// print_r($route);
//
// function scan($path) {
//     $path = './protected';
//     $files = scandir($path);
//     $route = [];
//     foreach ($files as $file) {
//         if ($file == '.' || $file == '..') {
//             continue;
//         }
//         if (is_dir($file)) {
//             if ($file!='module' || $file!='controllers') {
//                 continue;
//             }
//             scan($file);
//         }
//
//         // controller
//         if (!preg_match('/(\w+)Controller.php/', $file, $match)) {
//             continue;
//         }
//         $controllerName = lcfirst($match[1]);
//
//         // action
//         $p = $path . '/' . $file;
//         $content = file_get_contents($p);
//         preg_match_all('/public function action(\w+)/', $content, $matches, PREG_PATTERN_ORDER);
//         if (!$matches) {
//             continue;
//         }
//         foreach ($matches[1] as $m) {
//             $actionName = lcfirst($m);
//             $route[] = sprintf('%s.%s.%s', 'teachingV3', $controllerName, $actionName);
//         }
//     }
// }





protected function beforeAction($action)
    {
        $std = new stdClass();
        $std->authID = Yii::app()->user->id;

        // $route = sprintf('%s.%s.%s',$this->module->getId(),Yii::app()->controller->id,$action->id);
        if(Yii::app()->user->checkAccess('updateOwnPost',['post'=>$std]))
        {
            // Y::rspMsg('yes');
        } else {
            // Y::rspError('no');
        }

        return parent::beforeAction($action);
    }


SELECT * FROM information_schema.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_SCHEMA='wkrbac' AND REFERENCED_TABLE_NAME='tbAuthItem' AND REFERENCED_COLUMN_NAME='name';
