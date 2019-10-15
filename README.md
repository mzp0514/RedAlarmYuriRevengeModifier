# RedAlarmYuriRevengeModifier
mzp0514 22:00 2019.10.15

直接调用 Cheat (id)   id说明如下\n
#define MAX_MONEY 0\n
#define MAX_CONSTRUCT_SPEED 1\n
#define MAX_TANK_SPEED 2\n
#define MAX_SOLDIER_SPEED 3\n
#define MAX_PLANE_SPEED 4\n
#define MAX_SHIP_SPEED 5\n
#define MAX_ELECTRICITY 6\n
#define OBJECT_UPGRADE 7\n
#define CONSTRCUCT_ANYWHERE 8\n
#define OPEN_RAID 9                //这项只能调用一次 不然会崩\n

2、将kernel32.inc 中 Process32FirstW 和 Process32NextW 中的W删掉
