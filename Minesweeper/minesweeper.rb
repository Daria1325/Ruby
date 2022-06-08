require 'ruby2d'

set background: 'black'
GRID_SIZE = 40
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE
BOMB_COUNT = 30
COLOR_GUESSED = 'olive'


class Game
    def initialize
        @bombs = []
        bombs_init

        @cells = []
        cells_init

        @guessed_cells=[]
        @finished = false
    end

    def bombs_init
        while @bombs.length < BOMB_COUNT
            x = rand(GRID_WIDTH)
            y = rand(GRID_HEIGHT)
            @bombs.push([x,y]) unless  @bombs.include?([x,y])
            
        end
    end

    def cells_init
        for x in (0..GRID_WIDTH)
            for y in (0..GRID_HEIGHT)
                sum = 0
                check = []
            unless @bombs.include?([x,y])
                for i in (1..8)
                    case i 
                    when 1
                        check = [x-1,y-1]
                    when 2
                        check = [x,y-1]
                    when 3
                        check = [x+1,y-1]
                    when 4
                        check = [x-1,y]
                    when 5
                        check = [x-1,y+1]
                    when 6
                        check = [x,y+1]
                    when 7
                        check = [x+1,y+1]
                    when 8
                        check = [x+1,y]
                    end
                    sum+=1 if @bombs.include?(check)
                end
            end
            @cells.push([x,y,sum])
            end

        end
    end

    def draw
        @cells.each do |cell|
            Square.new(x: cell[0] * GRID_SIZE, y: cell[1]*GRID_SIZE, size: GRID_SIZE-1, color: 'lime')
        end
    end

    def check_cell(x,y)
        x=x/GRID_SIZE
        y = y/GRID_SIZE
        num = num_of_cell(x,y)
        if @bombs.include?([x,y])
            game_lost
        elsif num==0
            draw_zeroes(x,y)
        else
            @guessed_cells.push([x,y])
            Square.new(x: x*GRID_SIZE, y: y*GRID_SIZE,size:GRID_SIZE-1, color:COLOR_GUESSED)
            Text.new(num.to_s, x: x*GRID_SIZE, y: y*GRID_SIZE, color:'white', size: 25)
        end

    end

    

    def similar_cell(x1,y1,x2,y2)
        [x1-1, x1, x1+1].include?(x2) && [y1-1,y1,y1+1].include?(y2)
    end

    def draw_zeroes(x,y)  

        zeroes = [[x,y]]
        Square.new(x: x*GRID_SIZE, y: y*GRID_SIZE,size:GRID_SIZE-1, color:COLOR_GUESSED)
        i=0

        while i< zeroes.length
            x= zeroes[i][0]
            y = zeroes[i][1]
            @guessed_cells.push(x,y)
            for item in @cells
                if similar_cell(x,y,item[0],item[1])
                    Square.new(x: item[0]*GRID_SIZE, y: item[1]*GRID_SIZE,size:GRID_SIZE-1, color:COLOR_GUESSED)
                    if num_of_cell(item[0],item[1])==0
                        zeroes.push([item[0],item[1]])
                    else
                        Text.new(item[2].to_s, x: item[0]*GRID_SIZE, y: item[1]*GRID_SIZE, color:'white', size: 25)
                        @guessed_cells.push(item[0],item[1])
                    end
                end
            end
            i+=1
            zeroes = zeroes.uniq
        end
       

        
        
    end

    def num_of_cell(x,y)
        for item in @cells
            if item[0]==x && item[1]==y
                return item[2]
            end
        end
    end

    def game_over(msg)
        @bombs.each do |bomb|
            Square.new(x: bomb[0] * GRID_SIZE, y: bomb[1]*GRID_SIZE, size: GRID_SIZE-1, color: 'red')
        end
        Text.new(msg,x:100, y: 200, color:'black', size:40)
        @finished = true
    end

    def game_lost
        game_over("YOU FAILD THE GAME")
    end

    def game_win
        if  @cells.length - @bombs.length - @guessed_cells.length == 0
            game_over("YOU WON THE GAME")
        end
    end
    
    def finished?
        @finished
    end

end

game = Game.new
game.draw

on :mouse_down do |event|
    
    unless game.finished?
        game.check_cell(event.x, event.y)
        game.game_win
    end
    
end

on :key_down do |event|
    if event.key =='r'
        clear
        game = Game.new
        game.draw
    end
end


show