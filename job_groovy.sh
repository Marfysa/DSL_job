def GIT_URL = "https://github.com/Marfysa/build-t00ls.git"  
def arr = ["MNTLAB-mkurakevich-child1-build-job", "MNTLAB-mkurakevich-child2-build-job", "MNTLAB-mkurakevich-child3-build-job", "MNTLAB-mkurakevich-child4-build-job"]
job('MNTLAB-mkurakevich-main-build-job') {
  description 'Main'
  parameters {
    activeChoiceParam('BRANCH_NAME') {
      description('Branch name')
        choiceType('SINGLE_SELECT')
        groovyScript {
        script("""def gitURL = GIT_URL
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
           description('Child jobs')
           choiceType('CHECKBOX')
           groovyScript {
               script('return ["MNTLAB-mkurakevich-child1-build-job", "MNTLAB-mkurakevich-child2-build-job", "MNTLAB-mkurakevich-child3-build-job", "MNTLAB-mkurakevich-child4-build-job"]')
           }
    }
    
    
  scm {
    git {
      remote {
        url GIT_URL
      }
      branch '$BRANCH_NAME'
    }
  }
   steps {
    triggerBuilder {
      configs {
        blockableBuildTriggerConfig {
          projects('$CHILD_NAMES')
          block {
            buildStepFailureThreshold('FAILURE')
            unstableThreshold('UNSTABLE')
            failureThreshold('FAILURE')
          }
          configs {
            predefinedBuildParameters {
              properties('BRANCH_NAME=$BRANCH_NAME')
              textParamValueOnNewLine(false)
            }
          } 
        }
      }
    } 
  }
 }
}


    

for(jobs in arr) {
  
	job(jobs) {
      
 	description 'Child job'
      
  	parameters {
    	stringParam('BRANCH_NAME', '', 'Branche name')
    }  
      
    
    steps {
        maven {
            rootPOM 'home-task/pom.xml'
  		              	goals 'clean install'
            mavenInstallation('mvn3')
        }
      	shell('echo $BRANCH_NAME') 
        shell('java -cp home-task/target/hw3-app-1.0-SNAPSHOT.jar com.test.Project > output.log')
        shell('tar -czvf ${BRANCH_NAME}_dsl_script.tar.gz output.log')
	      shell('tar -czvf ${BRANCH_NAME}_dsl_script.tar.gz $JENKINS_HOME')
    }

   scm {
    git {
      remote {
        url GIT_URL
      }
      branch '$BRANCH_NAME'
    }
  }

  
   
  publishers {
        archiveArtifacts('${BRANCH_NAME}_dsl_script.tar.gz')
    }
}
}
