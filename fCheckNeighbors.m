function states_sum = fCheckNeighbors(zycieBoard, state, row, col)
    [height, width] = size(zycieBoard);
    if ((row > 2 && row < height-1) && (col > 2 && col < width-1))  
        neighbors = zycieBoard((row-2):(row+2), (col-2):(col+2));
        states_sum = sum(neighbors(:) == state);
    else
        states_sum = 0;
    end
end