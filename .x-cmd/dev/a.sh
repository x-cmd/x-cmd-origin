param <<A
    --org     "Provide organization"      =nullable
    --repo    "Provide work"              =nullable
    --direction=abc "" == abc dec a
    --meter=333   ""   =~ [0-9]{1,3}
A



param <<A
    --org,-o  <organziation-name>       "Provide organization"      
        =str   [A-Za-z0-9_]+            > gitee repo list
        =int   1  2  3
    --repo,-r <repo name>               "Provide work"              
        =nullable
    --access,-a <priviledge>
        =   public   private  inner-public
    --pair  <elem1>   <elem2>
        =int  1 2 3
        =int  7 8 9
A


param <<A
Options:
    --org|-o                            "Provide"
    --repo|-r <repo name>               "Provide repo name"     =int

Subcommands:
    test        
    work        
    work
A

