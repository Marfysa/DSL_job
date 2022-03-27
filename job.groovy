def GIT_URL = "https://github.com/Marfysa/build-t00ls.git"  
def arr = ["MNTLAB-mkurakevich-child1-build-job", "MNTLAB-mkurakevich-child2-build-job", "MNTLAB-mkurakevich-child3-build-job", "MNTLAB-mkurakevich-child4-build-job"]
job('MNTLAB-mkurakevich-main-build-job') {
  description 'Main'
  parameters {
    activeChoiceParam('BRANCH_NAME') {
      description('Branch name')
        choiceType('SINGLE_SELECT')
        groovyScript {
        script("""def gitURL = $GIT_URL
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
    activeChoiceReactiveParam('CHILD_NAMES') {
           description('Childe jobs')
           choiceType('CHECKBOX')
           groovyScript {
               script('return ["MNTLAB-mkurakevich-child1-build-job", "MNTLAB-mkurakevich-child2-build-job", "MNTLAB-mkurakevich-child3-build-job", "MNTLAB-mkurakevich-child4-build-job"]')
           }
    }
