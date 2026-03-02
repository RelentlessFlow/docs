# MC 命令

```shell
wget https://dl.min.io/client/mc/release/linux-amd64/mc -O mc
chmod +x mc

./mc alias set local http://10.6.6.105:19199 oss-qiyansoft-com-admin Qiyan-Oss-Soft-@n21-fje2-Ajdz-J1z

./mc --version
# 创建 4 个桶
./mc mb local/minio-public
./mc mb local/minio-private
./mc mb local/minio-ai
./mc mb local/minio-ai-private
# 设置公共桶的匿名读权限（公开访问）
./mc anonymous set download local/minio-public
./mc anonymous set download local/minio-ai
# 设置私有桶为完全私有
./mc anonymous set none local/minio-private
./mc anonymous set none local/minio-ai-private

./mc anonymous get local/minio-public
./mc anonymous get local/minio-private
./mc anonymous get local/minio-ai
./mc anonymous get local/minio-ai-private
```

创建凭证

```shell
[qiyan_yzq@qiyandata-com-test-env minio]$ ./mc admin accesskey create local/
Access Key: SA63Z98H9ZYM0PFYWI9V
Secret Key: kT1+4WVEad9AekNrJOSabU5C8No0z+DJbROAsrgD
Expiration: NONE
Name: 
Description: 
[qiyan_yzq@qiyandata-com-test-env minio]$ 
```

