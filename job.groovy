def GIT_URL = "https://github.com/Marfysa/DSL_job.git"  
job('MNTLAB-mkurakevich-main-build-job') {
  parameters {
        activeChoiceParam('BRANCH_NAME') {
            description('Allows user choose from multiple choices')
            choiceType('SINGLE_SELECT')
            groovyScript {
                script("""def gitURL = "$GIT_URL"
                          def command = "git ls-remote -h \$gitURL"
                          def proc = command.execute()
                          proc.waitFor()
                            if ( proc.exitValue() != 0 ) {
                              println "Error, \${proc.err.text}"
                              System.exit(-1)
                              }
                         def branches = proc.in.text.readLines().collect {
                           it.replaceAll(/[a-z0-9]*\\trefs\\/heads\\//, '')
                         }
                          return branches
                         """)
                fallbackScript()
            }
        }
      activeChoiceParam('CHILD_JOBS') {
        description('Jobs for execution')
          choiceType('CHECKBOX')
          groovyScript {
          script('["MNTLAB-mkurakevich-child1-build-job", "MNTLAB-mkurakevich-child2-build-job", "MNTLAB-mkurakevich-child3-build-job", "MNTLAB-mkurakevich-child4-build-job"]')
          fallbackScript()
      }
    }
  }  


