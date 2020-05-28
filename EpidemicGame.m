close all;
clear all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% USTAWIENIA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rozmiar = 200;              % rozmiar planszy: NxN
liczbaCykli = 200;          % ile iteracji zrobic
infectedNum = 3;            % poczatkowa liczba chorych

isSelfProtection = 1;       % Czy zarzadzono osobista ochrone? (maseczki, rekawice...)      
isPublicProtection = 1;     % Czy zarzadzono ochrone publiczna? (dezynfekcja, ograniczenia przemieszczania siê)
ventilators_amount = rozmiar*rozmiar*0.005; %0.0003125?

rozmiar = rozmiar+4; % dodanie krawedzi ze wzgledu na sasiedztwo	   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% PRAWDOPODOBIEÑSTWA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Formula:
% prob_StanObecny_MozliwyStanKolejny[_wPoblizuZarazonego/wPoblizuChorego]
% Dla kazdego StanObecny w sumie nie wiecej niz 100

prob_quarantine_healthy                     = 70;
prob_quarantine_recovered                   = 25;
prob_quarantine_hospital                    = 5;
prob_sick_quarantine                        = 5;
prob_sick_healthy                           = 94;
prob_infected_infectedSick                  = 20;
prob_infected_recovered                     = 20;
prob_infectedSick_quarantine                = 40;
prob_infectedSick_hospital                  = 20;
prob_infectedSick_recovered                 = 29;
prob_infectedSick_dead                      = 1;
prob_hospital_dead_enoughVents              = 20;
prob_hospital_dead_lackOfVents              = 50;
prob_hospital_recovered_enoughVents         = 79;
prob_hospital_recovered_lackOfVents         = 49;
prob_hospital_healthy                       = 1;

if (~isSelfProtection && ~isPublicProtection)
    prob_healthy_infected_byInfected        = 40;
    prob_healthy_infected_byInfectedSick    = 60;
    prob_healthy_quarantine_byInfectedSick  = 1;
    
elseif (isSelfProtection && ~isPublicProtection)
    prob_healthy_infected_byInfected        = 15;
    prob_healthy_infected_byInfectedSick    = 23;
    prob_healthy_quarantine_byInfectedSick  = 5;
    
elseif (~isSelfProtection && isPublicProtection)
    prob_healthy_infected_byInfected        = 30;
    prob_healthy_infected_byInfectedSick    = 40;
    prob_healthy_quarantine_byInfectedSick  = 50;
    
elseif (isSelfProtection && isPublicProtection)
    prob_healthy_infected_byInfected        = 12;
    prob_healthy_infected_byInfectedSick    = 19;
    prob_healthy_quarantine_byInfectedSick  = 70;
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALGORYTM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zycie = uint8(zeros(rozmiar,rozmiar)); % biezaca plansza zycia
zyciePom= uint8(zeros(rozmiar,rozmiar)); % plansza pomocnicza do odtwarzania zycia "za chwile"
zycieZeros = uint8(zeros(rozmiar,rozmiar)); % plansza optymalizujaca, zerujaca, pomocnicza

STAT_healthy_cnt        = zeros(1, liczbaCykli);
STAT_quarantine_cnt     = zeros(1, liczbaCykli);
STAT_infected_cnt       = zeros(1, liczbaCykli);
STAT_sick_cnt           = zeros(1, liczbaCykli);
STAT_infected_sick_cnt  = zeros(1, liczbaCykli);
STAT_in_hospital_cnt    = zeros(1, liczbaCykli);
STAT_recovered_cnt      = zeros(1, liczbaCykli);
STAT_dead_cnt           = zeros(1, liczbaCykli);

% x_start = randi(rozmiar);
% y_start = randi(rozmiar);
% 
% zycie(y_start, x_start) = StateQ1.INFECTED;

for n=1:infectedNum
    x_start = randi(rozmiar);
    y_start = randi(rozmiar);
    zycie(y_start, x_start) = StateQ1.INFECTED; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n=1:liczbaCykli

    %--- KROK 1 ----------------------------------------------------
    % Wizualizacja i statystyki obecnej iteracji
    
    zycie_image = uint8(zeros(rozmiar, rozmiar, 3));
    
    STAT_healthy_cnt(n)         = sum(zycie(:)==StateQ1.HEALTHY);
    STAT_quarantine_cnt(n)      = sum(zycie(:)==StateQ1.IN_QUARANTINE);
    STAT_infected_cnt(n)        = sum(zycie(:)==StateQ1.INFECTED);
    STAT_sick_cnt(n)            = sum(zycie(:)==StateQ1.SICK);
    STAT_infected_sick_cnt(n)   = sum(zycie(:)==StateQ1.INFECTED_SICK);
    STAT_in_hospital_cnt(n)     = sum(zycie(:)==StateQ1.IN_HOSPITAL);
    STAT_recovered_cnt(n)       = sum(zycie(:)==StateQ1.RECOVERED);
    STAT_dead_cnt(n)            = sum(zycie(:)==StateQ1.DEAD);
    
    zycie_image(:,:,1) = (zycie==StateQ1.HEALTHY)*255 + ...
                         (zycie==StateQ1.IN_QUARANTINE)*152 + ...
                         (zycie==StateQ1.INFECTED)*255 + ...
                         (zycie==StateQ1.SICK)*255 + ...
                         (zycie==StateQ1.INFECTED_SICK)*255 + ...
                         (zycie==StateQ1.IN_HOSPITAL)*0 + ...
                         (zycie==StateQ1.RECOVERED)*153 + ...
                         (zycie==StateQ1.DEAD)*0;
    
    zycie_image(:,:,2) = (zycie==StateQ1.HEALTHY)*255 + ...
                         (zycie==StateQ1.IN_QUARANTINE)*51 + ...
                         (zycie==StateQ1.INFECTED)*128 + ...
                         (zycie==StateQ1.SICK)*255 + ...
                         (zycie==StateQ1.INFECTED_SICK)*0 + ...
                         (zycie==StateQ1.IN_HOSPITAL)*0 + ...
                         (zycie==StateQ1.RECOVERED)*255 +...
                         (zycie==StateQ1.DEAD)*0;
                     
    zycie_image(:,:,3) = (zycie==StateQ1.HEALTHY)*255 + ...
                         (zycie==StateQ1.IN_QUARANTINE)*255 + ...
                         (zycie==StateQ1.INFECTED)*0 + ...
                         (zycie==StateQ1.SICK)*0 + ...
                         (zycie==StateQ1.INFECTED_SICK)*0 + ...
                         (zycie==StateQ1.IN_HOSPITAL)*255 + ...
                         (zycie==StateQ1.RECOVERED)*255 +...
                         (zycie==StateQ1.DEAD)*0;
    
    figure(1)
    imshow(zycie_image, 'InitialMagnification', 400), drawnow;
    text(2,2.5,['Cykl ' num2str(n)]);
    
        
    %--- KROK 2 ----------------------------------------------------
    % Obliczanie kolejnej iteracji
    if (STAT_infected_cnt(n) == 0)
        break
    end
    
    if (STAT_in_hospital_cnt(n) > ventilators_amount)
        prob_hospital_dead = prob_hospital_dead_lackOfVents;
        prob_hospital_recovered = prob_hospital_recovered_lackOfVents;
    else
        prob_hospital_dead = prob_hospital_dead_enoughVents;
        prob_hospital_recovered = prob_hospital_recovered_enoughVents;
    end
        
    zyciePom = zycie;
    zycieNeighbors_sick = zycieZeros;
    zycieNeighbors_infected = zycieZeros;
    prob_m = randi(101,rozmiar);
    
    tic;
    for w=1:rozmiar
        for k=1:rozmiar
            switch(zycie(w,k))
                case StateQ1.RECOVERED
                    zyciePom(w,k) = StateQ1.RECOVERED;
                    
                case StateQ1.DEAD
                    zyciePom(w,k) = StateQ1.DEAD;
                    
                case StateQ1.HEALTHY
                % Dla kazdej komorki HEALTHY obliczam liczbe sasiadow
                % zarazonych i chorych, a od wyniku uzalezniam
                % prawdopodobienstwo zarazenia sie
                    if (prob_m(w,k) == 70) % szum 1% - mala szansa na bycie chorym na cos innego
                        zyciePom(w,k) = StateQ1.SICK;
                    end
                    if (fCheckNeighbors(zycie, StateQ1.INFECTED_SICK, w, k) > 0)
                        if (prob_m(w,k) < prob_healthy_infected_byInfectedSick) 
                            zyciePom(w,k) = StateQ1.INFECTED;
                        elseif (prob_m(w,k) < prob_healthy_infected_byInfectedSick+prob_healthy_quarantine_byInfectedSick)
                            zyciePom(w,k) = StateQ1.IN_QUARANTINE;
                        end
                    else
                        if ((fCheckNeighbors(zycie, StateQ1.INFECTED, w, k) > 8) && (prob_m(w,k) < 2*prob_healthy_infected_byInfected))
                            zyciePom(w,k) = StateQ1.INFECTED;
                        elseif ((fCheckNeighbors(zycie, StateQ1.INFECTED, w, k) > 0) && (prob_m(w,k) < prob_healthy_infected_byInfected))
                            zyciePom(w,k) = StateQ1.INFECTED;
                        end
                    end
                        
                case StateQ1.IN_QUARANTINE
                    if (prob_m(w,k) < prob_quarantine_healthy)
                        zyciePom(w,k) = StateQ1.HEALTHY;
                    elseif (prob_m(w,k) < prob_quarantine_healthy+prob_quarantine_recovered)
                        zyciePom(w,k) = StateQ1.RECOVERED;
                    elseif (prob_m(w,k) < prob_quarantine_healthy+prob_quarantine_recovered+prob_quarantine_hospital)
                        zyciePom(w,k) = StateQ1.IN_HOSPITAL;
                    end
                    
                case StateQ1.INFECTED
                    if (prob_m(w,k) < prob_infected_infectedSick)
                        zyciePom(w,k) = StateQ1.INFECTED_SICK;
                    elseif (prob_m(w,k) < prob_infected_infectedSick+prob_infected_recovered)
                        zyciePom(w,k) = StateQ1.RECOVERED;
                    else
                        zyciePom(w,k) = StateQ1.INFECTED;
                    end
                    
                case StateQ1.SICK
                    if (prob_m(w,k) < prob_sick_quarantine)
                        zyciePom(w,k) = StateQ1.IN_QUARANTINE;
                    elseif (prob_m(w,k) < prob_sick_quarantine+prob_sick_healthy)
                        zyciePom(w,k) = StateQ1.HEALTHY;
                    else
                        zyciePom(w,k) = StateQ1.SICK;
                    end
                    
                case StateQ1.INFECTED_SICK
                    if (prob_m(w,k) < prob_infectedSick_quarantine)
                        zyciePom(w,k) = StateQ1.IN_QUARANTINE;
                    elseif (prob_m(w,k) < prob_infectedSick_quarantine+prob_infectedSick_hospital)
                        zyciePom(w,k) = StateQ1.IN_HOSPITAL;
                    elseif (prob_m(w,k) < prob_infectedSick_quarantine+prob_infectedSick_hospital+prob_infectedSick_recovered)
                        zyciePom(w,k) = StateQ1.RECOVERED;
                    elseif (prob_m(w,k) < prob_infectedSick_quarantine+prob_infectedSick_hospital+prob_infectedSick_recovered+prob_infectedSick_dead)
                        zyciePom(w,k) = StateQ1.DEAD;
                    else
                        zyciePom(w,k) = StateQ1.INFECTED_SICK;
                    end
                    
                case StateQ1.IN_HOSPITAL
                    if (prob_m(w,k) < prob_hospital_dead)
                        zyciePom(w,k) = StateQ1.DEAD;
                    elseif (prob_m(w,k) < prob_hospital_dead+prob_hospital_recovered)
                        zyciePom(w,k) = StateQ1.RECOVERED;
                    elseif (prob_m(w,k) < prob_hospital_dead+prob_hospital_recovered+prob_hospital_healthy)
                        zyciePom(w,k) = StateQ1.HEALTHY;
                    else
                        zyciePom(w,k) = StateQ1.IN_HOSPITAL;
                    end
            end     
        end
    end
    toc;
    
    %--- KROK 3 ----------------------------------------------------
    % przepisuje wartosci z zyciePom do zycie
    zycie= zyciePom;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VISUALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
it = 1:n;
    
figure(2);          
bar(it,STAT_healthy_cnt(1:n)); sgtitle('STATS healthy');
saveas(gcf,'STAT_healthy_cnt.svg');
figure(3);          
bar(it,STAT_quarantine_cnt(1:n)), sgtitle('STATS in quarantine');
saveas(gcf,'STAT_quarantine_cnt.svg');
figure(4);          
bar(it,STAT_infected_cnt(1:n)), sgtitle('STATS infected');
saveas(gcf,'STAT_infected_cnt.svg');
figure(5);          
bar(it,STAT_sick_cnt(1:n)), sgtitle('STATS sick (but not COVID)');
saveas(gcf,'STAT_sick_cnt.svg');
figure(6);  
bar(it,STAT_infected_sick_cnt(1:n)), sgtitle('STATS infected sick');
saveas(gcf,'STAT_infected_sick_cnt.svg');
figure(7);          
bar(it,STAT_in_hospital_cnt(1:n)), sgtitle('STATS in hospital');
saveas(gcf,'STAT_in_hospital_cnt.svg');
figure(8);          
bar(it,STAT_recovered_cnt(1:n)), sgtitle('STATS recovered');
saveas(gcf,'STAT_recovered_cnt.svg');
figure(9);          
bar(it,STAT_dead_cnt(1:n)), sgtitle('STATS dead');
saveas(gcf,'STAT_dead_cnt.svg');

figure(10);
imshow(zycie_image, 'InitialMagnification', 400);
text(2,2.5,['cykl ' num2str(n)]);
saveas(gcf,'FINAL.svg');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
