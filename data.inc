ACTOR_RUN  equ 0
ACTOR_JUMP1 equ 1
ACTOR_JUMP2 equ 2
ACTOR_CROUCH equ 3

NONE_OBSTACLE equ 0
UP_OBSTACLE equ 1
DOWN_OBSTACLE equ 2

UP_OBSTACLE_HEIGHT equ 30
DOWN_OBSTACLE_GAP equ 50

GOLDEN_COIN equ 30
SILVER_COIN equ 20
RAINBOW_COIN equ 10
DUCK_BISCUIT equ 25
BEAR_BISCUIT equ 15
NONE_ELEMENT equ 0

ACTOR_WIDTH equ 80
ACTOR_RUN_HEIGHT equ 80
ACTOR_CROUCH_HEIGHT equ 40

UP_OB_WIDTH equ 64
UP_OB_HEIGHT equ 96
DOWN_OB_WIDTH equ 64
DOWN_OB_HEIGHT equ 128



;跳跃初始速度
INITIAL_SPEED equ 16
;重力加速度
ACCELERATE_SPEED equ 1
;地面基准高度
GROUND_BASE equ 416

MAPPOINT_LENGTH equ 32
ELEMENTS_LENGTH equ 18
NUMBER_LENGTH equ 48

MapPoint STRUCT

	ground_y SDWORD GROUND_BASE
	obstacleType SDWORD NONE_OBSTACLE	
	elements SDWORD ELEMENTS_LENGTH DUP(GOLDEN_COIN)
MapPoint ends 

MapBufferSize equ 2816
MapSize equ 2560

MapNum equ 20


.data
	
	actor_x SDWORD 200
	actor_y SDWORD 300
	
	base_x SDWORD 200
	base_y SDWORD 300
	
	actorSpeed_x SDWORD 6
	actorSpeed_y SDWORD 0
	
	totalScore SDWORD 0
	firstDigit SDWORD 0
	secondDigit SDWORD 0
	thirdDigit SDWORD 0
	
	actorState SDWORD 0
	actorImage SDWORD 0
	
	leftFringe SDWORD 32
	
	;Map information
	Map1 db "Map1.txt",0
	Map2 db "Map2.txt",0
	Map3 db "Map3.txt",0
	Map4 db "Map4.txt",0
	Map5 db "Map5.txt",0
	Map6 db "Map6.txt",0
	
   	
   	MapBuffer db MapBufferSize DUP(?)
   	MapFlag db MapSize DUP(?)
	
	gMap MapPoint 2560 DUP(<>)
	gMap1 MapPoint 128 DUP(<>)
	gMap2 MapPoint 128 DUP(<>)
	gMap3 MapPoint 128 DUP(<>)
	gMap4 MapPoint 128 DUP(<>)
	gMap5 MapPoint 128 DUP(<>)
	gMap6 MapPoint 128 DUP(<>)
	
	firstStage DWORD 1, 2, 3, 4, 5, 6, 4, 5, 1, 3, 5, 2, 6, 1, 4, 6, 3, 1, 4, 5
	