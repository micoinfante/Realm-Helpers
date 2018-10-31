    class AWSUpload {
      func awsUpload(pathString: String) {
          print("AWS UPLOAD")


          let fileURL = URL(fileURLWithPath: pathString)
          let newVideo = Date()

          let uploadRequest = AWSS3TransferManagerUploadRequest()
          uploadRequest?.body = fileURL as URL

          uploadRequest?.key = String(describing: newVideo) + ".mov"
          uploadRequest?.bucket = "transit.mico"
          uploadRequest?.acl = AWSS3ObjectCannedACL.publicRead
          uploadRequest?.contentType = "movie/mov"

          writeToRealm(source: (uploadRequest?.key)!) // add url to realmdb

          print("#####UPLOADING####")
          uploadRequest?.uploadProgress = { (byteSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
              DispatchQueue.main.async(execute: {
                  let amountUploaded = totalBytesSent
                  let progress = (totalBytesSent / totalBytesExpectedToSend) * 100
                  print("Uploaded: \(amountUploaded) : \(progress)%")
              })
          }

          let transferManager = AWSS3TransferManager.default()
          transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task) in
              if task.error != nil {
                  print(task.error.debugDescription)
              } else{
                  print("done")
              }
              return nil
          })
      }

          func writeToRealm(source: String) {
          print("WRITING TO REALM")
          //        SyncUser.current?.logOut()

          let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: Constants.REALM_URL))
          let realm = try! Realm(configuration: config)
          print("INSIDE REALM: \(Constants.REALM_URL)")


          let video = Video()
          video.videoId = video.incrementVideoId() + 5
          video.caption = "test caption"
          video.views = 555
          video.source = source

          //                            print("Database Path : \(config.fileURL!)")
          try! realm.write {
              realm.add(video)
              print("##SUCCESSFULLY ADDED A VIDEO##")
          }

      }// add to realm
    }
