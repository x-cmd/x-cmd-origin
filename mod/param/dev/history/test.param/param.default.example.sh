. param

(
    param.default app/gitee a 1
    param.default app/gitee b 1
    param.default app/gitee c 1
    param.default app/gitee ugly "\"abc'"

    echo "List all key/values in scope app/gitee:"
    param.default app/gitee

    echo "Save scope app/gitee to file:"
    param.default.save app/gitee ./app.gitee.config.log

    echo "Load scope app/gitee to file:"
    param.default.load app/gitee ./app.gitee.config.log
)


echo "---------------"

echo "List all key/values in scope app/gitee:"
param.default app/gitee

echo "Load app/gitee."
param.default.load app/gitee ./app.gitee.config.log

echo "List all key/values in scope app/gitee:"
param.default app/gitee

