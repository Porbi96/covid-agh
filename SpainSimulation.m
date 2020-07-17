close all;
clear all;
clc;

% set the values ??then press Run

%%% SETTINGS %%%

boardSize = 100;              % board Size
itNumber = 100;               % iteration number
init_infectedNum = 3;         % start infected number   

SelfProtection = 0;           % bool (0 or 1)
PublicProtection = 0;         % bool (0 or 1)
	   
% probability of transitions between states:

prob_quarantine_healthy                     = 75;
prob_quarantine_recovered                   = 20;
prob_quarantine_hospital                    = 5;
prob_sick_quarantine                        = 8;
prob_sick_healthy                           = 91;
prob_infected_infectedSick                  = 20;
prob_infected_recovered                     = 20;
prob_infectedSick_quarantine                = 43;
prob_infectedSick_hospital                  = 25;
prob_infectedSick_recovered                 = 29;
prob_infectedSick_dead                      = 3;
prob_hospital_dead             				= 20;
prob_hospital_recovered				        = 79;
prob_hospital_healthy                       = 1;

% protection type:

if (~SelfProtection && ~PublicProtection)
    prob_healthy_infected_byInfected        = 29;
    prob_healthy_infected_byInfectedSick    = 70;
    prob_healthy_quarantine_byInfectedSick  = 1;
    
elseif (SelfProtection && ~PublicProtection)
    prob_healthy_infected_byInfected        = 15;
    prob_healthy_infected_byInfectedSick    = 23;
    prob_healthy_quarantine_byInfectedSick  = 5;
    
elseif (~SelfProtection && PublicProtection)
    prob_healthy_infected_byInfected        = 25;
    prob_healthy_infected_byInfectedSick    = 40;
    prob_healthy_quarantine_byInfectedSick  = 50;
    
elseif (SelfProtection && PublicProtection)
    prob_healthy_infected_byInfected        = 10;
    prob_healthy_infected_byInfectedSick    = 17;
    prob_healthy_quarantine_byInfectedSick  = 70;
end

HEALTHY = 0;
IN_QUARANTINE = 1;
INFECTED = 2;
SICK = 3;
INFECTED_SICK = 4;
IN_HOSPITAL = 5;
RECOVERED = 6;
DEAD = 7;

boardSize = boardSize+4;
liveBoard = uint8(zeros(boardSize,boardSize));
liveBoard_temp1= uint8(zeros(boardSize,boardSize));
liveBoard_temp2 = uint8(zeros(boardSize,boardSize));

cnt_healthy        = zeros(1, itNumber);
cnt_quarantine     = zeros(1, itNumber);
cnt_infected       = zeros(1, itNumber);
cnt_sick           = zeros(1, itNumber);
cnt_infected_sick  = zeros(1, itNumber);
cnt_in_hospital    = zeros(1, itNumber);
cnt_recovered      = zeros(1, itNumber);
cnt_dead           = zeros(1, itNumber);

for n=1:init_infectedNum
    x_start = randi(boardSize);
    y_start = randi(boardSize);
    liveBoard(y_start, x_start) = INFECTED; 
end

for n=1:itNumber
    
    live_img = uint8(zeros(boardSize, boardSize, 3));
    
    cnt_healthy(n)         = sum(liveBoard(:)==HEALTHY);
    cnt_quarantine(n)      = sum(liveBoard(:)==IN_QUARANTINE);
    cnt_infected(n)        = sum(liveBoard(:)==INFECTED);
    cnt_sick(n)            = sum(liveBoard(:)==SICK);
    cnt_infected_sick(n)   = sum(liveBoard(:)==INFECTED_SICK);
    cnt_in_hospital(n)     = sum(liveBoard(:)==IN_HOSPITAL);
    cnt_recovered(n)       = sum(liveBoard(:)==RECOVERED);
    cnt_dead(n)            = sum(liveBoard(:)==DEAD);
    
    live_img(:,:,1) = (liveBoard==HEALTHY)*255 + ...
                         (liveBoard==IN_QUARANTINE)*249 + ...
                         (liveBoard==INFECTED)*236 + ...
                         (liveBoard==SICK)*115 + ...
                         (liveBoard==INFECTED_SICK)*253 + ...
                         (liveBoard==IN_HOSPITAL)*47 + ...
                         (liveBoard==RECOVERED)*32 + ...
                         (liveBoard==DEAD)*0;
    
    live_img(:,:,2) = (liveBoard==HEALTHY)*255 + ...
                         (liveBoard==IN_QUARANTINE)*191 + ...
                         (liveBoard==INFECTED)*51 + ...
                         (liveBoard==SICK)*172 + ...
                         (liveBoard==INFECTED_SICK)*34 + ...
                         (liveBoard==IN_HOSPITAL)*71 + ...
                         (liveBoard==RECOVERED)*255 +...
                         (liveBoard==DEAD)*0;
                     
    live_img(:,:,3) = (liveBoard==HEALTHY)*255 + ...
                         (liveBoard==IN_QUARANTINE)*38 + ...
                         (liveBoard==INFECTED)*218 + ...
                         (liveBoard==SICK)*148 + ...
                         (liveBoard==INFECTED_SICK)*39 + ...
                         (liveBoard==IN_HOSPITAL)*240 + ...
                         (liveBoard==RECOVERED)*32 +...
                         (liveBoard==DEAD)*0;
    
    figure(1)
    imshow(live_img, 'InitialMagnification', 400), drawnow;
    text(2,2.5,['Cykl ' num2str(n)]);
    
    if (cnt_infected(n) == 0)
        break
    end
        
    liveBoard_temp1 = liveBoard;
    zycieNeighbors_sick = liveBoard_temp2;
    zycieNeighbors_infected = liveBoard_temp2;
    prob_m = randi(101,boardSize);
        
    for w=1:boardSize
        for k=1:boardSize
            switch(liveBoard(w,k))
                case RECOVERED
                    liveBoard_temp1(w,k) = RECOVERED;
                    
                case DEAD
                    liveBoard_temp1(w,k) = DEAD;
                    
                case HEALTHY
                    if (prob_m(w,k) == 1)
                        liveBoard_temp1(w,k) = SICK;
                    end
                    if (fNeighborsState(liveBoard, INFECTED_SICK, w, k) > 0)
                        if (prob_m(w,k) < prob_healthy_infected_byInfectedSick) 
                            liveBoard_temp1(w,k) = INFECTED;
                        elseif (prob_m(w,k) < prob_healthy_infected_byInfectedSick+prob_healthy_quarantine_byInfectedSick)
                            liveBoard_temp1(w,k) = IN_QUARANTINE;
                        end
                    else
                        if ((fNeighborsState(liveBoard, INFECTED, w, k) > 8) && (prob_m(w,k) < 2*prob_healthy_infected_byInfected))
                            liveBoard_temp1(w,k) = INFECTED;
                        elseif ((fNeighborsState(liveBoard, INFECTED, w, k) > 0) && (prob_m(w,k) < prob_healthy_infected_byInfected))
                            liveBoard_temp1(w,k) = INFECTED;
                        end
                    end
                        
                case IN_QUARANTINE
                    if (prob_m(w,k) < prob_quarantine_healthy)
                        liveBoard_temp1(w,k) = HEALTHY;
                    elseif (prob_m(w,k) < prob_quarantine_healthy+prob_quarantine_recovered)
                        liveBoard_temp1(w,k) = RECOVERED;
                    elseif (prob_m(w,k) < prob_quarantine_healthy+prob_quarantine_recovered+prob_quarantine_hospital)
                        liveBoard_temp1(w,k) = IN_HOSPITAL;
                    end
                    
                case INFECTED
                    if (prob_m(w,k) < prob_infected_infectedSick)
                        liveBoard_temp1(w,k) = INFECTED_SICK;
                    elseif (prob_m(w,k) < prob_infected_infectedSick+prob_infected_recovered)
                        liveBoard_temp1(w,k) = RECOVERED;
                    else
                        liveBoard_temp1(w,k) = INFECTED;
                    end
                    
                case SICK
                    if (prob_m(w,k) < prob_sick_quarantine)
                        liveBoard_temp1(w,k) = IN_QUARANTINE;
                    elseif (prob_m(w,k) < prob_sick_quarantine+prob_sick_healthy)
                        liveBoard_temp1(w,k) = HEALTHY;
                    else
                        liveBoard_temp1(w,k) = SICK;
                    end
                    
                case INFECTED_SICK
                    if (prob_m(w,k) < prob_infectedSick_quarantine)
                        liveBoard_temp1(w,k) = IN_QUARANTINE;
                    elseif (prob_m(w,k) < prob_infectedSick_quarantine+prob_infectedSick_hospital)
                        liveBoard_temp1(w,k) = IN_HOSPITAL;
                    elseif (prob_m(w,k) < prob_infectedSick_quarantine+prob_infectedSick_hospital+prob_infectedSick_recovered)
                        liveBoard_temp1(w,k) = RECOVERED;
                    elseif (prob_m(w,k) < prob_infectedSick_quarantine+prob_infectedSick_hospital+prob_infectedSick_recovered+prob_infectedSick_dead)
                        liveBoard_temp1(w,k) = DEAD;
                    else
                        liveBoard_temp1(w,k) = INFECTED_SICK;
                    end
                    
                case IN_HOSPITAL
                    if (prob_m(w,k) < prob_hospital_dead)
                        liveBoard_temp1(w,k) = DEAD;
                    elseif (prob_m(w,k) < prob_hospital_dead+prob_hospital_recovered)
                        liveBoard_temp1(w,k) = RECOVERED;
                    elseif (prob_m(w,k) < prob_hospital_dead+prob_hospital_recovered+prob_hospital_healthy)
                        liveBoard_temp1(w,k) = HEALTHY;
                    else
                        liveBoard_temp1(w,k) = IN_HOSPITAL;
                    end
            end     
        end
    end
    liveBoard= liveBoard_temp1;
end

iteration = 1:itNumber;
    
figure(2);          
bar(iteration,cnt_healthy); sgtitle('healthy number');
saveas(gcf,'healthy_number.svg');
figure(3);          
bar(iteration,cnt_quarantine), sgtitle('in quarantine number');
saveas(gcf,'in_quarantine_number.svg');
figure(4);          
bar(iteration,cnt_infected), sgtitle('infected number');
saveas(gcf,'infected_number.svg');
figure(5);          
bar(iteration,cnt_sick), sgtitle('sick number');
saveas(gcf,'sick_number.svg');
figure(6);  
bar(iteration,cnt_infected_sick), sgtitle('infected sick number');
saveas(gcf,'infected_sick_number.svg');
figure(7);          
bar(iteration,cnt_in_hospital), sgtitle('in hospital number');
saveas(gcf,'in_hospital_number.svg');
figure(8);          
bar(iteration,cnt_recovered), sgtitle('recovered number');
saveas(gcf,'recovered_number.svg');
figure(9);          
bar(iteration,cnt_dead), sgtitle('dead number');
saveas(gcf,'dead_number.svg');
figure(10);
imshow(live_img, 'InitialMagnification', 400);
sgtitle('Final iteration');
text(2,2.5,['cykl ' num2str(n)]);
saveas(gcf,'Final_iteration.svg');

dead_sum = cnt_dead(n);

function states_sum = fNeighborsState(zycieBoard, state, row, col)
    [height, width] = size(zycieBoard);
    if ((row > 2 && row < height-1) && (col > 2 && col < width-1))  
        neighbors = zycieBoard((row-2):(row+2), (col-2):(col+2));
        states_sum = sum(neighbors(:) == state);
    else
        states_sum = 0;
    end
end
