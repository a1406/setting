<?php
$servername = "mysql";
$username = "root";
$password = "111111";


$conn = mysqli_connect($servername, $username, $password);
if(!$conn){
    die("数据库连接错误" . mysqli_connect_error());
}else{
    echo"数据库连接成功";
}

?>

