ACTOR_RUN  equ 0
ACTOR_JUMP1 equ 1
ACTOR_JUMP2 equ 2
ACTOR_LIE equ 3

NONE_OBSTACLE equ 0
UP_OBSTACLE equ 1
DOWN_OBSTACLE equ 2

UP_OBSTACLE_HEIGHT equ 30
DOWN_OBSTACLE_GAP equ 64

GOLDEN_COIN equ 30
SILVER_COIN equ 20
RAINBOW_COIN equ 10
DUCK_BISCUIT equ 25
BEAR_BISCUIT equ 15
NONE_ELEMENT equ 0

ACTOR_WIDTH equ 96
ACTOR_RUN_HEIGHT equ 96
ACTOR_LIE_HEIGHT equ 64
ACTOR_JUMP_SIZE equ 112

FIGURE_WIDTH equ 128
FIGURE_HEIGHT equ 128
FIGURE_Y equ 150
FIGURE_X equ 100

ARROW_SIZE equ 128


UP_OB_WIDTH equ 64
UP_OB_HEIGHT equ 96
DOWN_OB_WIDTH equ 64
DOWN_OB_HEIGHT equ 64


;跳跃初始速度
INITIAL_SPEED equ 16
;重力加速度
ACCELERATE_SPEED equ 1
;地面基准高度
GROUND_BASE equ 416
;X坐标的限制=2560*32-2*1024
TotalXLimit equ 79872

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
	
	base_x SDWORD 168
	base_y SDWORD 300
	
	actorSpeed_x SDWORD 6
	actorSpeed_y SDWORD 0
	
	totalScore SDWORD 0
	firstDigit SDWORD 0
	secondDigit SDWORD 0
	thirdDigit SDWORD 0
	fourthDigit SDWORD 0
	fifthDigit SDWORD 0
	
	actorState SDWORD 0
	actorImage SDWORD 0
	actorLie SDWORD 0
	
	;小人被阻塞
	isBlocked DWORD 0
	;左边界
	leftFringe SDWORD 32
	;游戏状态
	gameSucceed db "mark:000000" ,0
   	gameOver db "mark:000000", 0
   	gameSucceedTitle db "You Win!",0
   	gameOverTitle db "Game Over!",0
   	isGameOver dd 0
   	
   	figureNum dd 4
   	startGame dd 0
   	stateChanged dd 0
   	figureChosen dd 1
	
	;Map information
	Map1 db "SubMap1.txt",0
	Map2 db "SubMap2.txt",0
	Map3 db "SubMap3.txt",0
	Map4 db "SubMap4.txt",0
	Map5 db "SubMap5.txt",0
   	
   	MapBuffer db MapBufferSize DUP(?)
   	MapFlag db MapSize DUP(?)
	
	gMap MapPoint 2560 DUP(<>)
	gMap1 MapPoint 128 DUP(<>)
	gMap2 MapPoint 128 DUP(<>)
	gMap3 MapPoint 128 DUP(<>)
	gMap4 MapPoint 128 DUP(<>)
	gMap5 MapPoint 128 DUP(<>)
	
	firstStage DWORD 1, 2, 3, 4, 5, 3, 1, 2, 3, 2, 5, 1, 2, 4, 4, 5, 4, 3, 5, 1
	