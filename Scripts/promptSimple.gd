extends Control

## variable identifiers
@onready var connected1 = $MultiplayerController/P1
@onready var connected2 = $MultiplayerController/P2
@onready var connected3 = $MultiplayerController/P3
@onready var connected4 = $MultiplayerController/P4
@onready var username = $MultiplayerController/NameInput
@onready var user1 = $Scoreboard/ScoreNames/User1
@onready var user2 = $Scoreboard/ScoreNames/User2
@onready var user3 = $Scoreboard/ScoreNames/User3
@onready var user4 = $Scoreboard/ScoreNames/User4

## network data
var number_of_peers

## User text input
var user_input : String
var user : String

## Score counters
var response_o := 0
var response_x := 0
var score = response_o
var response_number = 0

## Switch variables
var wait_switch = 0
var wait_response = 0
var pressed_amount = 0
var loop_count = 0
var player_count = 0

## Input data storage
var submission = []
var player_names = []


func _ready() -> void:
	$WaitScreen.hide()
	$ResponseO.hide()
	$ResponseX.hide()


func _process(delta: float) -> void:
	number_of_peers = multiplayer.get_peers().size() + 1
	$ScoreLabel.text = str(response_o)
	wait.rpc(wait_switch)
	if number_of_peers == 1:
		connected1.color = Color(0, 1, 1, 1)
	if number_of_peers == 2:
		connected2.color = Color(0, 1, 1, 1)
	if number_of_peers == 3:
		connected3.color = Color(0, 1, 1, 1)
	if number_of_peers == 4:
		connected4.color = Color(0, 1, 1, 1)
	if number_of_peers == player_count:
		get_player_count.rpc()

	#print("peers: ", number_of_peers)
	#print(wait_switch)


@rpc("any_peer", "call_local")
func wait(wait_switch):
	#check_player_count.rpc()
	if wait_switch == number_of_peers:
		$WaitScreen.hide()
	if wait_response == (number_of_peers * number_of_peers):
		$AnswerScreen.hide()
		$AnswerInput.show()
		hide_response()
		wait_response = 0
		pressed_amount = 0
		submission.clear()
		print("looped wait response: ", wait_response)
		print("looped pressed amount: ", pressed_amount)
		print("looped submission: ", submission)

#@rpc("any_peer", "call_local")
func response_signal():
	response_number += 1
	print("rp is ", response_number)
	print(number_of_peers)
	if response_number == 1:
		$ResponseO.hide()
		$ResponseX.hide()
		response_number = 0
	else:
		pass

@rpc("any_peer", "call_local")
func add():
	wait_switch += 1

@rpc("any_peer", "call_local")
func subtract():
	wait_switch = 0

@rpc("any_peer", "call_local")
func start():
	$MultiplayerController.hide()
	$Scoreboard.show()

@rpc("any_peer", "call_local")
func get_player_count():
	player_count = number_of_peers
	#print(player_count)
	
	
@rpc("any_peer", "call_local")
func submit(info):
	submission.append(info)
	
@rpc("any_peer", "call_local")
func test1():
	$AnswerScreen/AnswerLabel.text = submission[0]
	
@rpc("any_peer", "call_local")
func test2():
	if wait_response == number_of_peers:
		$AnswerScreen/AnswerLabel.text = submission[1]
		loop_count += 1
		$ResponseO.show()
		$ResponseX.show()

@rpc("any_peer", "call_local")
func test3():
	if wait_response == number_of_peers * 2:
		$AnswerScreen/AnswerLabel.text = submission[2]
		loop_count += 1
		$ResponseO.show()
		$ResponseX.show()

@rpc("any_peer", "call_local")
func test4():
	if wait_response == number_of_peers * 3:
		$AnswerScreen/AnswerLabel.text = submission[3]
		loop_count += 1
		$ResponseO.show()
		$ResponseX.show()

@rpc("any_peer", "call_local")
func iterate_wait_response():
	wait_response += 1
	
@rpc("any_peer", "call_local")
func remove_waiting_for_start():
	$MultiplayerController/WaitingStartButton.hide()

@rpc("any_peer", "call_local")
func set_player_names(names):
	player_names.append(names)

@rpc("any_peer", "call_local")
func set_scoreboard():
# Scoreboard names
	if player_names.size() == 2:
		user1.text = player_names[0]
		user2.text = player_names[1]
		user3.hide()
		user4.hide()
	elif player_names.size() == 3:
		user1.text = player_names[0]
		user2.text = player_names[1]
		user3.text = player_names[2]
		user4.hide()
	elif player_names.size() == 4:
		user1.text = player_names[0]
		user2.text = player_names[1]
		user3.text = player_names[2]
		user4.text = player_names[3]
	print(player_names)

	#print("Peer joined with ID:", new_peer_id)
	#print(player_scores)


func hide_response():
	$ResponseO.hide()
	$ResponseX.hide()
	
	
func show_response():
	$ResponseO.show()
	$ResponseX.show()


func _on_start_button_pressed() -> void:
	set_scoreboard.rpc()
	start.rpc()
	remove_waiting_for_start.rpc()
	$MultiplayerController.hide()


func joined():
	$MultiplayerController/HostButton.hide()
	$MultiplayerController/JoinButton.hide()
	if multiplayer.is_server():
		$MultiplayerController/SyncButton.show()
	

func _on_answer_input_text_submitted(new_text: String) -> void:
	if $AnswerInput.text == "":
		$AnswerInput.placeholder_text = "Spill some tea!"
	else:
		add.rpc()
		user_input = $AnswerInput.text
		submit.rpc(user_input)
		$WaitScreen.show()
		$AnswerInput.hide()
		show_response()
		$AnswerScreen.show()
		test1.rpc()
		print(submission)


func _on_response_x_pressed() -> void:
	response_x += 1
	pressed_amount += 1
	response_signal()
	iterate_wait_response.rpc()
	$NHIE.text = str("Never Have I Ever...")
	$AnswerInput.text = ""
	$AnswerInput.placeholder_text = "Hit em' with your best secrets"
	subtract.rpc()
	test2.rpc()
	if pressed_amount == 2 and (number_of_peers == 3 or number_of_peers ==  4):
		test3.rpc()
	else:
		pass
	if pressed_amount == 3 and number_of_peers == 4:
			test4.rpc()
	print("wait response: ", wait_response)
	print("pressed amount: ", pressed_amount)
	print("current label: ", $AnswerScreen/AnswerLabel.text)


func _on_response_o_pressed() -> void:
	response_o += 1
	pressed_amount += 1
	response_signal()
	iterate_wait_response.rpc()
	$NHIE.text = str("Never Have I Ever...")
	$AnswerInput.text = ""
	$AnswerInput.placeholder_text = "Hit em' with your best secrets"
	subtract.rpc()
	test2.rpc()
	if pressed_amount == 2 and (number_of_peers == 3 or number_of_peers ==  4):
		test3.rpc()
	else:
		pass
	if pressed_amount == 3  and number_of_peers == 4:
			test4.rpc()
	print("wait response: ", wait_response)
	print("pressed amount: ", pressed_amount)
	print("current label: ", $AnswerScreen/AnswerLabel.text)


func _on_host_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1027)
	get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	multiplayer.multiplayer_peer = peer
	joined()
	$MultiplayerController/SyncButton.hide()
	username.show()
	$MultiplayerController/SubmitNameButton.show()
	$MultiplayerController/PlayerWaitScreen.show()
	print("Connected to Server")


func _on_join_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.1", 1027)
	get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	multiplayer.multiplayer_peer = peer
	joined()
	if multiplayer.is_server():
		$MultiplayerController/SyncButton.show()
	else:
		username.show()
		$MultiplayerController/SubmitNameButton.show()
	

func _on_submit_name_button_pressed() -> void:
	if username.text == "":
		username.placeholder_text = "You need a name, sweetie."
	elif multiplayer.is_server() and player_count != number_of_peers:
		username.text = ""
		username.placeholder_text = "not enough players!"
	elif multiplayer.is_server() and player_count == number_of_peers:
		user = username.text
		$MultiplayerController/SyncButton.show()
		username.hide()
		$MultiplayerController/SubmitNameButton.hide()
		set_player_names.rpc(user)
	elif not multiplayer.is_server() and player_count != number_of_peers:
		username.text = ""
		username.placeholder_text = "not enough players!"
	elif not multiplayer.is_server() and player_count == number_of_peers:
		user = username.text
		username.hide()
		$MultiplayerController/SubmitNameButton.hide()
		$MultiplayerController/WaitingStartButton.show()
		set_player_names.rpc(user)


func _on_sync_button_pressed() -> void:
	$MultiplayerController/ConnectedPlayers.hide()
	$MultiplayerController/P1.hide()
	$MultiplayerController/P2.hide()
	$MultiplayerController/P3.hide()
	$MultiplayerController/P4.hide()
	$MultiplayerController/SyncButton.hide()
	$MultiplayerController/StartButton.show()


func _on_two_players_pressed() -> void:
	player_count = 2
	$MultiplayerController/PlayerWaitScreen.hide()
	$MultiplayerController/ConnectedPlayers.show()
	$MultiplayerController/P1.show()
	$MultiplayerController/P2.show()
	
	
func _on_three_players_pressed() -> void:
	player_count = 3
	$MultiplayerController/PlayerWaitScreen.hide()
	$MultiplayerController/ConnectedPlayers.show()
	$MultiplayerController/P1.show()
	$MultiplayerController/P2.show()
	$MultiplayerController/P3.show()


func _on_four_players_pressed() -> void:
	player_count = 4
	$MultiplayerController/PlayerWaitScreen.hide()
	$MultiplayerController/ConnectedPlayers.show()
	$MultiplayerController/P1.show()
	$MultiplayerController/P2.show()
	$MultiplayerController/P3.show()
	$MultiplayerController/P4.show()
	
