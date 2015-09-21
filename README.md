** HOW TO USE **  

./sim-bad-net.sh start #1 #2 #3 #4  
    #1: delay               The amont of delay in ms  
    #2: delay-variation     The delay variation, ms as well  
    #3: package-loss        The amount of package-loss you want to see in %  
    #4: corruption          The amount of corruption you want to see in %  


./sim-bad-net.sh stop  

** EXAMPLES **  
    % ./sim-bad-net.sh start 500 100 10 0.5  
    % ./sim-bad-net.sh stop  
