def play_game():
    
    p1_score = 0
    p2_score = 0
    
    def fun(p1, p2):
        nonlocal p1_score, p2_score
        if p1 == "stone":
            if p2 == "stone":
                p1_score += 0
                p2_score += 0
            elif p2 == "paper":
                p1_score += 0
                p2_score += 1
            elif p2 == "scissors":
                p1_score += 1
                p2_score += 0
        elif p1 == "paper":
            if p2 == "stone":
                p1_score += 1
                p2_score += 0
            elif p2 == "paper":
                p1_score += 0
                p2_score += 0
            elif p2 == "scissors":
                p1_score += 0
                p2_score += 1
        elif p1 == "scissors":
            if p2 == "stone":
                p1_score += 0
                p2_score += 1
            elif p2 == "paper":
                p1_score += 1
                p2_score += 0
            elif p2 == "scissors":
                p1_score += 0
                p2_score += 0
        else:
            print("Error: Please check your input")
    
    rounds = 5
    
    for r in range(rounds):
        print("Round: " + str(r+1))
        player1 = input("Player 1: Enter stone, paper, or scissors: ")
        player2 = input("Player 2: Enter stone, paper, or scissors: ")
        
        fun(player1, player2)
    
    print('-------RESULT---------')    
    print("Player 1 score:", p1_score)
    print("Player 2 score:", p2_score)
    
    if p1_score > p2_score:
        print("Player 1 wins!")
    elif p1_score < p2_score:
        print("Player 2 wins!")
    else:
        print("It's a tie!")
        
    play_again = input("Do you want to start a new game? (yes/no): ")
    if play_again.lower() == "yes":
        play_game()
    else:
        print("Game over.")

play_game()
