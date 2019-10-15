# RedAlarmYuriRevengeModifier
mzp0514 22:00 2019.10.15

直接调用 Cheat (id)   id说明如下

#define MAX_MONEY 0

#define MAX_CONSTRUCT_SPEED 1

#define MAX_TANK_SPEED 2

#define MAX_SOLDIER_SPEED 3

#define MAX_PLANE_SPEED 4

#define MAX_SHIP_SPEED 5

#define MAX_ELECTRICITY 6

#define OBJECT_UPGRADE 7

#define CONSTRCUCT_ANYWHERE 8

#define OPEN_RAID 9                //这项只能调用一次 不然会崩



2、将kernel32.inc 中 Process32FirstW 和 Process32NextW 中的W删掉
