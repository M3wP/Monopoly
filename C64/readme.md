# MONOPOLY 

VERSION 0.02.02 ALPHA


FOR THE COMMODORE 64

BY DANIEL ENGLAND FOR ECCLESTIAL SOLUTIONS


(C) 2018 DANIEL ENGLAND
ALL RIGHTS RESERVED


MONOPOLY IS THE PROPERTY OF HASBRO INC.

(C) 1935, 2016 HASBRO



You probably need to own a copy of the official board game to even be reading
this.  *ugh*


I feel this is how the game should be played...


## Introduction


The goal has been to make an implementation as close to the standard as 
possible.  However, a strict, turn-based structure to the game is more-or-less 
required when attempting to have multiple players on a single console.  A few
changes to the rules would be required, then.  An official release of the game 
for the C64 back in the day was nightmarishly slow and cumbersome for trying to 
avoid these changes (rent nomination delays, waiting endlessly for the dice and 
strange menus).  All other new releases I have seen, on modern hardware, have
the same structure as used here, strictly turn-based, and the same related rule 
changes.

Some rules in the standard set are not entirely specific.  Many technicalities 
of the standard rules are largely unseen in the wild.  Every version I know of 
lacks the improvement auctions, for example.  I am adhering to the standard 
rules in relation to eliminations, trades and auctions better than any other 
version I know of.

## Rule Changes

The game is identical to the most recent, standard rules as per my copy 
(Australia, 2018) except for the following details:

* Rent is always paid, there is no need to declare it owed.  I'll put a
note here.  When paying, only the amount available to the player is 
paid in the case where they do not have sufficient wealth (equity + 
money, see the deductions/observations section).  As to the rule 
change, having to declare it is nonsense, especially when the board 
has markers for player ownership.  Also, in this single console 
implementation, trying to incorporate the standard rule would only 
serve to drastically reduce the rate of play (as it probably does for 
the board game) and I feel it could generally only foster the 
development of anticompetitive behaviour.  I know of no version (other 
than the original C64 one) that doesn't simply always charge rent.
* Trade initiation can only be done in the player's turn (when they 
"have the dice") or when it is their turn during an auction (see 
below).  I discuss the trade implementation issues thoroughly in the 
deductions/observations section.  Overall, I think this is a fair 
interpretation given the platform/structure restrictions.
* As for the most strange case, trade initiation is not permitted 
when receiving deeds from an elimination.  Ordinarily, a player
is eliminated when it is their turn so this does not happen. 
However, if I was to always allow trading when it was your turn then 
it could happen that due to the Community Chest card that requires 
other players to pay you and you are receiving deeds from an elimination, 
you could trade.  This is an extraordinarily rare, corner-case (it is only 
$10) and it seems  better, in the interests of fairness, all player's best 
interests and providing a standard mechanism, that it is not allowed.  Again, 
trades in the standard rules can be at "any time" but there is no 
mention of them in the standard rules pertaining to the transfer (they
only state simple possible actions) nor which action might have 
priority when paying and dissolving equity.  This rule brings a degree of
simplicity to the mechanisms.
* House/Hotel (improvement) and mortgage management can always be 
done in the player's turn.  It can can also be done when offered a 
trade or receiving a defeated player's deeds for example, when a 
player has gone into debt out of turn (see the deductions/observations 
section for more information).  All of these events occur 
sequentially, not concurrently.  This will affect how improvements are 
sold and their availability.
* As a side effect of the above, there is no auctioning of houses/hotels 
which should occur by the standard rules if there are multiple demands 
for them (and there is an insufficient number to meet demand) since 
they are bought and sold in-turn.  I'll note here that the standard 
rules are somewhat vague as to how these (perhaps just houses, even) 
improvement auctions actually occur, anyway.  Out of all the changes, 
this is perhaps the biggest although it might not seem that way.  It
is certainly the one I'm most upset about having to follow.  
* Auctions of deeds are also turn-based.  If all but one player passes 
in a round, the player that did bid wins the auction.  A player may 
forfeit any further bids in their turn, effectively always passing
for the remainder of the auction.  As per the standard rules, all 
players can pass or forfeit and no one will win the auction, the deed
will remain unclaimed.  Auctions also start at $10, as per the 
standard rules and this is the minimum bid value in this version.  The 
standard rules don't clearly specify if lower opening values are 
actually permitted or not (its a reserve) but the idea seems to be 
that it is a minimum asking price.
* The standard debt recovery rules are always applied to their furthest
extent when a player has insufficient wealth in this version.  The 
standard rules are absolutely amiss in regards to specifically 
detailing what occurs when a player is defeated by another player and 
how they should manage the debt.  Applying this convention as an 
assertion is the only truly logical and fair decision.  Too many of 
the standard rules are vague in relation to the matters involved and 
not having this particular rule would open many of them up to peculiar 
interpretation.  One of them would even be what I would consider to be 
broken if not following this as a rule because it does not specify 
what should happen when there is an alternative, something the 
standard rules don't specifically disclaim.  Having this rule in place 
clears up a number of issues.  I will discuss the issues further in 
the deductions/observations section.
* The Community Chest and Chance cards are reshuffled when the last is
returned (independently, of course).  The standard rules don't mandate 
this.  I feel this is a more interesting behaviour.  I may be persuaded 
to make this a house rule however I strongly prefer it as is.
* When you are able to use a Get Out Gaol Free card, the standard rules
would allow you to use any that you have but in this implementation, 
the Community Chest one is used first and then the Chance one, if both 
are owned.  This is for the sake of simplicity.  I'm happy to take on
board any valid criticism of this decision but having to select would
be a disproportionate complication of the mechanisms.
* Gaol is spelt "G A O L" instead of "J A I L" because that's how it 
was on the board I played on as a child and I prefer the old or even
correct spelling.  I'm not intending on using American "spelling" and 
place names any time soon but perhaps for an NTSC version (see known 
issues).
* The maximum amount of money each player can have in this version is 
fixed at $32767.  The odd value is due to the implementation.  It is 
still an extremely high amount of money to have, even for a game by 
the standard rules.  For example, the standard board game version only 
comes with $15140 in printed money.  I have played games where I had 
some $12000 money or so and only half of the maximum equity during 
testing but they were uncommon.  I have heard of a house rule where 
you can only have the printed money in play but the standard rules do 
say that the banker is quite free to print more bills (which this 
version can effectively do to a very large extent).  


## House Rules

The following optional house rules are available (or considered):
	
* Starting money can be set low ($1000) or high ($2000).  I have
done this because I feel that with only two players, the normal
starting money is too low.  There just isn't enough capital in play
in my opinion.  $2000 for three players is questionably high but 
still works alright enough.  For four or more you probably want the 
normal amount.  I may expand the selection range.  I have been 
asked for $3000 but this is definitely too high.
* Taxes can be sent to and collected from Free Parking. 
I actually hate this house rule because it is insanely unbalanced and
can cause the game to drag on.  It is widely desired, however so I
provide it (it has been almost free in the implementation 
anyway).  Only taxes will be accumulated.
* I am considering the "double salary for actually landing on Go"
house rule but I feel it is largely redundant with a high starting
money option.
* Since I have mentioned it, I will field requests for the printed
bills only house rule (since there is always going to be some kind
of cap).  It would be implemented such that effectively, a best-fit
of bills would be applied (shuffling them about through all accounts).
So simply a total funds cap.


## Rule Observations and Deductions

The following deductions and observations are made from the rule changes that 
were required for this platform and from attempting to best incorporate the 
remaining rules unchanged:

* To clarify, equity refers to the amount of money the player has 
access to by dissolving their assets through the sale of improvements 
and the mortgaging of deeds.  Wealth refers to the total amount of 
money potentially available to the player -- that is, actual money 
plus equity.
* When a player's deeds are transferred after losing to another player,
if the recipient cannot afford at least the fee for a deed, the 
remaining, unpaid for deeds are auctioned to all players (as per 
losing to the bank).  I'll add some more detail here because there is 
a commonly unknown rule and it has not been implemented on any other 
version I've seen.  When a player loses to another player (after 
trying to pay by selling and mortgaging, see the point following the 
next), the "mortgaged deeds" (which one can assume is all of them 
owned by the defeated player) are transferred to the owed player but 
that player must either pay to repay each one or pay the 10% fees and 
keep the deeds mortgaged as decided by them, per deed.  Recall that 
mortgages are repaid by paying the mortgage value plus 10% (rounded 
up).  These charges are paid to the bank.  Conversely, when losing to 
the bank, the player's properties are all unmortgaged and auctioned. 
The standard rules do not specify what happens if the defeating player 
cannot pay, nor the order in which the deeds are paid for in.  They 
are also decidedly vague about what "these mortgaged deeds" should be 
and what happens to any other kind of deed the defeated player may 
have (which in this version isn't any because I do assume the 
standard debt recovery rules are completed in full).
* Further to the above, when a player has defeated another player, they
are able to determine which deeds they will take ownership of and
which deeds go to auction (within their means).  I have decided to do 
this because the player must pay and the standard rules are so vague 
in relation to the matter.  Instead of determining the priority order, 
I am allowing the player to do it.  This seems to be the only truly 
fair option and the most flexible interpretation of the standard rules.  
The only caveat is that once at auction, they may go for as low as $10 
which is lower than the fees for the big name deeds (from red or so 
onwards but not the stations).  Letting these deeds go is a big gamble. 
Big enough that I feel this assertion is still valid.  The player is 
still having to determine the deeds they will pay fees for or repay 
which is the only thing the standard rules are truly specific about 
requiring.  I will not force the player to go down to zero wealth in 
order to  attempt to stringently adhere to the standard rules by 
requiring they take as many deeds as possible when those rules don't 
specify what should happen when the player can't pay, anyway let alone 
the order they will be required to pay in.
* When a player has insufficient wealth to pay another player, they have
lost the game and all houses and hotels will be sold and all deeds 
mortgaged in order to attempt to pay.  All equity will be converted to
money and the total, remaining wealth transferred to the defeating 
player.  This requirement is somewhat vague in the rules (they do 
state that it is how a debt should be recovered, though).  However,
trades are supposedly possible "at any time".  I believe the specified 
mechanism should take priority over trades in order to avoid a 
drawn-out game.  The fact is that the standard rules clearly state 
that once incurred, expenses must be paid and don't truly specify 
other options of debt recovery and the priority for negotiating the
bank between paying the debts and managing trades is not specified. 
No version I have ever seen allows a trade to override a catastrophic 
debt let alone requiring traded mortgaged deed fees but theoretically, 
according to a strict interpretation of the standard rules, trading 
with a gullible player could get you out of debt at the midnight hour?
There is no (other) way to "resign" in the standard rules...  The 
following points will go on to prove that trades must take a back-seat
to debts.  Fully applying the debt recovery rules to their furthest 
extent, is the only logical behaviour.
* To be specific, when in debt (unable to pay from money) but have equity 
to cover those expenses, there is an established amount outstanding 
and it must be paid before the player can finish their turn.  A trade 
or other action cannot be initiated that would prevent this.  The 
standard rules state that rent and other expenses "must be paid" when 
declared or incurred (always in this version).  Debts must be 
recovered in some priority to other actions.
* A certainty is that trades must not be permitted if they would cause 
a losing state.  The menus will not allow a trade that would cause the 
player to lose due to a catastrophic reduction of wealth and know 
about fees and repay requirements.  That is, when trading, the 
repay or payment of fees requirement is placed on both parties for 
all mortgaged deeds in the trade as well.  You must pay to repay the 
mortgage or keep the deed in a mortgaged state and simply pay the 10%
fee.  These rules are almost unheard of but are standard rules. 
Again, I believe this is the only version I have ever known to include 
them.
* The standard rules state that a deed cannot be traded if any in the 
group has improvements on it.  In order to have improvements, the whole 
street group must be owned.  Therefore, if any of the group has 
improvements, none of the group can be traded.  I'm simply reiterating
this to be fully stated.
* When offered a trade, if the player cannot afford at least the fee as 
mentioned above for trading a mortgaged property, any remaining 
mortgaged properties would not be transferred and the trade would be 
incomplete.  As such, a player must have sufficient wealth to cover 
nominated or required fee and repayment charges in order to accept the 
trade.
* Players should review the trade information and be satisfied with how 
they will make repayments or fee payments for that trade and must have 
sufficient wealth to commit to the exchange.
* To ensure all of the above conditions, trades cannot be initiated when
the player is in debt nor can players utilise more equity than they 
currently have (before the trade is executed) in order to accommodate 
a trade agreement.  Mandating this is supported by the fact that the
term "immediately" is used where there are details in the standard rules
so one can assume that all deeds are transferred and all payments made in 
a single transaction.  Recall that debt repayments must be a priority to other 
actions and the only described mechanism for this in the standard 
rules is dissolving equity.  There would be an impact of the mortgage 
and dissolving process of the player in recovering debt that would 
affect any trade from that player.  Fair market value is at stake and 
for it to be fair to all players, trades must be a lower priority. 
The idea is to win the game.  
* When the player has gone into debt outside their turn, during a trade,
while receiving defeated player deeds or in some other way, the player 
is able to mortgage deeds and sell improvements ("manage" their 
portfolio).  This is to facilitate more timely trade arrangements and 
because players must be able to utilise their equity to recover 
commitments to the bank and other players in all instances.  This is
handled by a special game play interrupt mechanism in this version.  I
believe this provides a great deal of freedom inside the turn-based 
structure and is the most logical way of accommodating the possible 
actions.  When multiple players are in debt out of their turn, they 
are serviced in play order, starting with the next player after the 
current player (player "with the dice").  This will affect management 
options.
* When there are not enough houses available after breaking down a 
hotel, the number of outstanding, phantom houses must be sold in order
to continue.  The standard rules are unclear about how this is to 
happen precisely but assert that it is impossible to have more than 
the set number of houses or hotels on the board.  I have implemented 
it in the most fair manner possible.  In this way, the players can 
retrieve all of their equity which should be the expected outcome. 
Any of the player's houses can be sold to make up the numbers.  They
could theoretically juggle them however they liked, according to the
standard rules.  The player should be especially careful when breaking 
down multiple hotels in this condition.  It may be more of a problem
than it seems.
* If paying all players money from the Chance card and the player does 
not have sufficient wealth, the player will lose to the next player in 
play order that they cannot pay (not the bank as per other cards, except 
below) by using all their wealth to make the payments.  This is to be 
clear about how this card functions.  Some players may not get any of
their money, another only some.
* If receiving money from all players with the Community Chest card, if
a player cannot pay (insufficient wealth) then they will lose to the 
owed player (not the bank as per other cards, except above).  Again,
just to be clear.  Any number of players may lose to the owed player
and the owed player may not get all of the money.
* If you roll for the third time in attempting to get out of gaol, you
cannot then use a Get Out of Gaol Free card.  This is due to the fact
that the standard rules do not specifically allow it and the gaol 
rules are quite specific.
* When rolling for first turn, the lowest player wins when there is a 
tie.  Player one would win over player six.  The standard rules do not 
specify how this condition should be handled and its a pretty common 
one.  I used the path of least resistance.
* A score statistic is generated for each player based on their equity,
money and range of improvements.  It is quite simple to calculate.
This may be of interest in declaring a winner instead of playing 
until all but one player remains which can be difficult to achieve 
in some games, especially when no trade arrangements can be made.  I 
permit all players to agree to abandon the current game and a winner 
is declared, by default, based on the score.  Resignations actually do
not seem to be permitted by the standard rules. I am not permitting 
them on a player-by-player basis, either.  Its is calculated by:
 
		  [equity/2] + [money/8] + [#deeds] + 
		  [#gofree] + (foreach group [(#ingroup - 1)*2]) +
		  
		             50 | 100 | 150 | 200 |  for each street deed
		  1 house |   1 |   5 |  10 |  20 |
		  2 house |   2 |  15 |  20 |  35 |
		  3 house |   5 |  30 |  50 |  80 |
		  4 house |   7 |  40 |  70 | 110 |
		  1 hotel |  15 |  70 | 100 | 180 | +

		  #stations/2 * 2^#stations + #utilities		???



## Further Details

I have used a customised version of the GoatTracker 2.73 driver for this game.
I also used custom tools for it (I wanted the source code, not a "standardised"
binary module).  I modified the driver to not touch the third voice (it is used 
for random number generation in a unique way, instead of for producing sound) 
and in order to compile it with ca65.  Decent psudeo-random number generation 
is expensive for a MOS6502 so generating them with another "processor" is very 
convenient.  I should do tests to see how "natural" and "random" the values
generated are and if they match real dice closely enough but I am yet to do so.
From play-testing, I haven't noticed any peculiarities.  Theoretically, they
should be equal to anything I could reasonably do in a great deal more memory 
and time or perhaps better.  Also, I like that it potentially has a type of
rhythm.


## Compilation

To compile: 

	ca65 -g -l c64client.lst -o c64client.o c64client.s
    
	cl65 -t none c64client.o -Ln c64client.lbl -o c64client.prg

There are some more details about building the strings but these aren't 
available yet.

The game must also be run from the disk image so it too must be built.


## Running

Insert the disk.

LOAD"*",8

RUN


## Known Issues

* There seems to be an odd race condition which will, on occasion, cause
the game to not update correctly and hang at launch.  It only happens 
once in a hundred times when loading on VICE (and perhaps a real C64) 
but on the Mega65, it happens all the time unless the machine is warm 
booted prior to loading the game.  I have attempted to fix it but I
haven't succeeded.  I will now endeavour to debug if and when it
occurs in my testing.  From what I have been able to see, it seems
that the IRQ has not been acknowledged correctly when this occurs?
* If the game is launched in a non-default memory configuration (the 
VIC-II screen and charrom locations), it won't attempt to normalise 
the condition.  The game will be unplayable.  I should normalise the 
system configuration in the first-time initialisation.
* SFX often get lost and "music" breaks up because of the limited 
number of channels (two) available to play sounds on.  The third 
voice is used for random number generation.  Better performance may 
be achieved when I update to version 2.74 of the GoatTracker driver? 
Even though it is a more comfortable pace, using the stepping (not 
jumping) mode is worse for the sound.  You can play very fast in the 
jumping mode and cause some interesting squeaks too.
* The audio driver and IRQ handler is expecting a PAL machine.  You
will get strange results on an NTSC one, I expect.  I may release an
NTSC/PAL-N version in the future.
* Clicking too quickly with the joystick at the very start seems to
  cause the game to think you're using the mouse.  I might be able
  to fix this...

## TODO

* Statistics/Overview from trade approval, must pay.  They should work now.

* Should be able to do beta release state after above

* Could now instead of copy name on elimin and gameover dialogs, just refer.
* Backup/retrieve menu button selection going to/returning from dialogs when
  the menu hasn't changed?  Would be nice...
  
* Change trade jump menu naming and texts to action jump menu
* Fix texts on action jump menu

* CPU player still needs:  AutoRepay, AutoAuction, AutoTradeTo, AutoTradeWith,
  AutoElimin
* Will I need to load the rules constant data into high memory, too?
* Fix issue with CPU player and setup1 chosing invalid option.
* "Thinking" prompt when cpu engaged?  Its so fast anyway... 
* AutoBuy - there is a bug when reclaiming equity in order to sell that
  causes no money to be paid for sale
* AutoGaol incorrectly chose roll over post?

* Allow players to input name?
* Trim down key scan routine.
* Get exmomiser working.
* Change "all" dirty to be just board dirty and req. individual flags?
* Back-fit GoatTracker driver changes from version 2.74.
* Player sprites on overview dialog.  Would look pretty.  IRQ is a mess.
* Put code into separate files as indicated.
* Is rent3 SFX still a little lame?  Does it matter?  Are the sounds okay on 
  Android (where the emulation is terrible)?
* Properly divide game and rule routines.  
* Fix ZPage variable use, in particular active player pointer and IRQ.
* Fix IRQ handler -- its gotten hacked to death.
* Screen double buffering?  Is it required if the dirty/update code is 
  optimised?  Would be difficult - quite a bit of rework.
* Optimise, optimise, optimise (eg. BIT instead of LDA, AND/ORA trains).
  Self modifying code??  Need cartridge/ROM support?  Already modify many data 
  items.
* Check music/sfx - sometimes does not fire correctly at all (other than
  resource contention issue).  Perhaps fixed by 2.74?  Very rare issue.

## For Testing (Needs Confirmation):
* Player focus restored after player lose to player interrupt?
* Money cap (32767) not exceeded on addcash?
* Don't allow leave management when -ve hses, htls at all
* Must pay works from trade/elimination?
* Used GO Free cards prevented from appearing in deck until after 
  shuffle (and while owned by a player)
* Ensure all options/pages are displayed for all menus.

## Change History (Since Version 0.01.99A)
* 10JUL2018
	* Move rules constant data into high memory (and load at start).
	* Implement AutoConstruct for AutoImprove (need AutoRepay).
	* Fix spurious auctn0 menu redraws bug that is now causing crashes.
	* Optimise some routines.
	* CPU performs behaviour for setup (somewhat naughty).
	* CPU behaviour mechanisim now implemented.  
	* Implement key injection queue and processing.
	* Debug action processing.
* 09JUL2018
	* Beginning of cpu behaviours.  Remove features from debugging.
	* Beginnings of AutoPlay.  Only in debugging.
	* AutoGaol.  Only in debugging.
	* Add AutoBuy available from debugging.
* 08JUL2018
	* Buzz when fail get out free.
	* Fix order of buttons on trdsel0 dialog.
	* Autosell feature.  Still not properly incorporated into menus.
	* Load strings resource.  This is still very slow. *sigh*
	* Rip out strings and put in separate files.  I have built a strings.prg
	  file out of the process but I can't get exomiser to work yet so the
	  process is unfinalised.
	* Unload Kernal and use the machine bare.
	* Replace Kernal scankey with my own copy. *ugh*
* 07JUL2018
	* Rework trade stepping interrupt into a generic execute on the 
	  front-end feature, ui Actions.
	* Bump the version.  I have everything in from my initial requirements
	  (except for tidy up) and am now going beyond.
* 06JUL2018
	* Buzz when fail attempting to mortgage, construct or sell.
	* Change order of button on setup3 and setup5 menus to better 
	  reflect the usual selections and minimise movements.
	* Fix bug in menuDisplay affecting button selection.
	* Add game options, input config options to play menu.
	* Add another play menu (Play2) for statistics and quit.
	* Rework some setup menus (now use some tricks!).
	* Better order to setup menus, new labels.
	* Whoops, immediate mode in initMem.
	* Clear up "property" naming issues (streets/deeds/improvements).
	* Add menus and funtionality to initiate/confirm game quit.
	* Add player score to PStats dialog.
	* Calculate player score.
* 05JUL2018
	* Rework eliminations.  *Phew!*  The extra layers of interface and
	  processing makes this an overall increase to the executable size
	  which I was hoping to keep smaller than it is.
	* Navigate single cell buttons (money) more intuitively with
	  joystick (this was a surprisingly large change).
* 04JUL2018
	* Disable bid (and don't perform) when have insufficient money.
	* Disable all trade buttons when have negative money.
	* Fix show "doubles" on play menu.
	* Fix buttons bug closing non default drawn dialogs.
	* Optimise player name handling (some).
	* All button types supported for hot tracking.
	* Fix keys for buttons on PlyrSel menu.
	* Update some CCCCard texts.
	* Input sensitivity control when input is joystick.
	* Inform when 3 doubles is reason for gaol (in menu desc).
	* Inform when have doubles on play menu (in desc).
	* Hot track blinking.
	* Note to self:  Got all below in with data space saved.
	* Basic button hot tracking (still need more types support).
	* Complex joystick movement and button selection/input translation.
	* Detect mouse or joystick click for input config selection.
	* Rework mouse selection.
	* Add basic joystick driver and button selection.
	* Fix menu only updates affecting whole screen?
	* Allow only unique colours for each player.
	* Added more button types and auto draw, remove redundant data 
	  (saved about 800B of data!).
* 03JUL2018
	* Disable debug keys by default.
	* Disable filter in tunes at end to get SFX on channel 0 working better.
	* Implement Free Parking Taxes House Rule.
	* Add House Rules setup menu (Setup6).
	* Add statistics and enable trade option on Gaol2 menu.
	* Add a second page to the auctions menus.
	* Do not allow trades if player is in debt.
	* Use menuPush for Player Selection menu instead of return hack.
	  Just to mention, I'm not sure that returning to the second page of
	  some menus is the desired behaviour.  I don't know how to change this.
	* Allow up to two menu pages to be stored in its stack (just in case).
* 02JUL2018
	* Tweak some strings.
	* Optimise trade data area size (only need data for tradeable deeds).
	* Fixed display of # utilites on Players Stats dialog.
	* Fixed display of # stations on Players Stats dialog.
	* Fixed display of # of GO Free cards on Players Stats dialog.


### End of Transcript
