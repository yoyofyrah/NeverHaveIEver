extends Control

var user_input : String
var response_o := 0
var response_x := 0
var score = response_o
var wait_switch = 0
var number_of_peers
var answer = {}

func _ready() -> void:
	$WaitScreen.hide()
	$ResponseO.hide()
	$ResponseX.hide()
	#$Score.hide()


func _process(delta: float) -> void:
	number_of_peers = multiplayer.get_peers().size() + 1
	$ScoreLabel.text = str(response_o)
	wait.rpc(wait_switch)
	#print(wait_switch)
	#print(number_of_peers)


@rpc("any_peer", "call_local")
func wait(wait_switch):
	if wait_switch == number_of_peers:
		$WaitScreen.hide()

@rpc("any_peer", "call_local")
func add():
	wait_switch += 1

@rpc("any_peer", "call_local")
func subtract():
	wait_switch = 0

@rpc("any_peer", "call_local")
func start():
	$MultiplayerController.hide()

@rpc("any_peer", "call_local")
func response():
	answer[multiplayer.get_unique_id()] = user_input
	answer[multiplayer.get_remote_sender_id()] = user_input
	
@rpc("any_peer")
func share_answer(new_input):
	# Retrieve the sender's ID
	var sender_id = multiplayer.get_remote_sender_id()
	answer[sender_id] = new_input
	for stuff in answer.keys():
		$AnswerScreen/AnswerLabel.text = new_input

func _on_start_button_pressed() -> void:
	start.rpc()


func joined():
	$MultiplayerController/HostButton.hide()
	$MultiplayerController/JoinButton.hide()
	$MultiplayerController/NameInput.hide()
	

func _on_answer_input_text_submitted(new_text: String) -> void:
	add.rpc()
	user_input = $AnswerInput.text
	$WaitScreen.show()
	$AnswerInput.hide()
	$ResponseO.show()
	$ResponseX.show()
	$AnswerScreen.show()
	#$AnswerScreen/AnswerLabel.text = user_input
	response.rpc()
	response.rpc_id(multiplayer.get_remote_sender_id())
	
		# Store answer locally
	answer[multiplayer.get_unique_id()] = user_input
	
	# Broadcast input to all peers (including the server) 
	rpc("share_answer", user_input) 

	#print(answer)
	
	
func _on_response_x_pressed() -> void:
	response_x += 1
	$ResponseO.hide()
	$ResponseX.hide()
	$NHIE.text = str("Never Have I Ever...")
	$AnswerInput.text = ""
	$AnswerInput.show()
	subtract.rpc()


func _on_response_o_pressed() -> void:
	response_o += 1
	$ResponseO.hide()
	$ResponseX.hide()
	$NHIE.text = str("Never Have I Ever...")
	$AnswerInput.text = ""
	$AnswerInput.show()
	subtract.rpc()


func _on_host_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1027)
	get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	multiplayer.multiplayer_peer = peer
	joined()
	print("Connected to Server")


func _on_join_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.1", 1027)
	get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	multiplayer.multiplayer_peer = peer
	$MultiplayerController/StartButton.hide()
	joined()
