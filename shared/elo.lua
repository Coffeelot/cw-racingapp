ConfigELO = {
    positionBonusTwo = { 0.2, 0 }, -- used to give a bonus to winner if 2 racers
    positionBonusThree = { 0.5, 0.1, 0 }, -- used to give a bonus to winner and second if 3 racers
    positionBonusFour = { 1.2, 0.8, 0.4, 0 }, -- used to give a bonous to 1,2 and 3 if 4 racers
    positionBonusFive = { 1.5, 1, 0.5, 0.25, 0 }, -- like the above but for 5
    positionBonusOverFive = { 2, 1.5, 1, 0.5, 0.25 }, -- like the above but for rest
    winAgainstLowerRankMod = 0.02, -- scaling for if you win against lower ranked
    winAgainstHigherRankMod = 0.03, -- scaling if you win against higher ranking
    lossAgainstLowerRankMod = 0.02, -- scaling if you lose against lower ranked
    lossAgainstHigherRankMod = 0.006, -- scaling if you lose agasint higher ranking
}