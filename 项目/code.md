## jwt登录
```php
$curl = new Curl();
        $resp = $curl->post('http://127.0.0.1:9502/backend/user/login', ['data' => $data]);
        if (is_object($resp) && !empty($resp->data->token)) {
            /** @var Token $token */
            $token = Yii::$app->jwt->getParser()->parse((string)$resp->data->token);
            $uid = $token->getClaim('uid');
            if (!$uid) {
                return $this->asJson(['code' => 1001, 'msg' => '登录失败']);
            }

            Yii::$app->user->login(User::findOne($uid));
            Yii::$app->getSession()->set('token', (string)$token);
            return $this->asJson($resp);
        } else {
            return $this->asJson(['code' => 1002, 'msg' => '登录失败']);
        }
```