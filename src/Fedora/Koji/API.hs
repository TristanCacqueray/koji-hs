module Fedora.Koji.API
       ( Info(..)
       , koji
       , hello
       , checkTagAccess
       , checkTagPackage
       , getAPIVersion
       , getActiveRepos
       , getAllArches
       , getAllPerms
       , getArchive
       , getArchiveFile
       , getArchiveType
       , getArchiveTypes
       , getAverageBuildDuration
       , getBuild
       , getBuildConfig
       , getBuildLogs
       , getBuildTarget
       , getBuildTargets
       , getBuildType
       , getBuildroot
       , getBuildrootListing
       , getChangelogEntries
       , getChannel
       , getEvent
       , getExternalRepo
       , getExternalRepoList
       , getFullInheritance
       , getGlobalInheritance
       , getGroupMembers
       , getHost
       , getImageArchive
       , getImageBuild
       , getInheritanceData
       , getLastEvent
       , getLastHostUpdate
       , getLatestBuilds
       , getLatestMavenArchives
       , getLatestRPMS
       , getMavenArchive
       , getMavenBuild
       , getNextRelease
       , getPackage
       , getPackageConfig
       , getPackageID
       , getRPM
       , getRPMDeps
       , getRPMFile
       , getRPMHeaders
       , getRepo
       , getTag
       , getTagExternalRepos
       , getTagGroups
       , getTagID
       , getTaskChildren
       , getTaskDescendents
       , getTaskInfo
       , getTaskRequest
       , getTaskResult
       , getUser
       , getUserPerms
       , getVolume
       , getWinArchive
       , getWinBuild

       , listArchiveFiles
       , listArchives
       , listBTypes
       , listBuildRPMs
       , listBuildroots
       , listBuilds
       , listCGs
       , listChannels
       , listExternalRepos
       , listHosts
       , listPackages
       , listPackagesSimple
       , listRPMFiles
       , listRPMs
       , listSideTags
       , listTagged
       , listTaggedArchives
       , listTaggedRPMS
       , listTags
       , listTaskOutput
       , listTasks
       , listUsers
       , listVolumes

       , repoInfo
       , resubmitTask
       , tagChangedSinceEvent
       , tagHistory
       , taskFinished
       , taskReport

       , Value(..)
       , Struct
       , lookupStruct
--       , readStructString
--       , readStructArray
--       , readMethodParams
       , maybeVal
       , maybeStruct
       , getValue
       )
where

import Data.Maybe
--import Control.Monad.Fail (MonadFail)
--import qualified Data.ByteString.Lazy.Char8 as B
import Network.XmlRpc.Client
import Network.XmlRpc.Internals
--import Network.HTTP.Simple
--import Network.HTTP.Client.Conduit
import Control.Monad.Except (runExceptT)

hub :: String
hub = "https://koji.fedoraproject.org/kojihub"

koji :: Remote a =>
        String -- ^ command
     -> a
koji = remote hub

-- xmlrpc :: String -> String -> [Value] -> IO Value
-- xmlrpc url m args = do
--   initreq <- parseRequest url
--   let reqbody = renderCall (MethodCall m args)
--       request = setRequestBody (RequestBodyLBS reqbody) $ setRequestMethod "POST" initreq
--   resp <- httpLBS request
--   let respbody = getResponseBody resp
--   handleError fail $ (parseResponse (B.unpack respbody) >>= handleResponse)
--   where
--     -- | Gets the return value from a method response.
--     --   Throws an exception if the response was a fault.
--     handleResponse :: MonadFail m => MethodResponse -> m Value
--     handleResponse (Return v)       = return v
--     handleResponse (Fault code str) = error ("Error " ++ show code ++ ": " ++ str)

type Struct = [(String,Value)]

maybeString :: Maybe String -> Value
maybeString = maybe ValueNil ValueString

maybeInt :: Maybe Int -> Value
maybeInt = maybe ValueNil ValueInt

maybeValue :: Maybe Value -> Value
maybeValue = fromMaybe ValueNil

data Info = InfoID Int | InfoString String

infoValue :: Info -> Value
infoValue (InfoID i) = ValueInt i
infoValue (InfoString s) = ValueString s

maybeInfo :: Maybe Info -> Value
maybeInfo = maybe ValueNil infoValue

maybeStruct :: Value -> Maybe Struct
maybeStruct (ValueStruct st) = Just st
maybeStruct _ = Nothing


-- https://koji.fedoraproject.org/koji/api

-- CG*

-- _listapi()

-- add*

-- applyVolumePolicy(build, strict=False)

-- assignTask(task_id, host, force=False)

-- build(src, target, opts=None, priority=None, channel=None)

-- buildContainer(src, target, opts=None, priority=None, channel='container')

-- buildImage(name, version, arch, target, ksfile, img_type, opts=None, priority=None)

-- buildImageIndirection(opts=None, priority=None)

-- buildImageOz(name, version, arches, target, inst_tree, opts=None, priority=None)

-- buildReferences(build, limit=None, lazy=False)

-- cancelBuild(buildID)

-- cancelTask(task_id, recurse=True)

-- cancelTaskChildren(task_id)

-- cancelTaskFull(task_id, strict=True)

-- chainBuild(srcs, target, opts=None, priority=None, channel=None)

-- chainMaven(builds, target, opts=None, priority=None, channel='maven')

-- changeBuildVolume(build, volume, strict=True)

-- | checkTagAccess(tag_id, user_id=None)
checkTagAccess :: Int -> Int -> IO Value
checkTagAccess = koji "checkTagAccess"

-- | checkTagPackage(tag, pkg)
checkTagPackage :: Info -> Info -> IO Bool
checkTagPackage taginfo pkginfo = koji "checkTagPackage" (infoValue taginfo) (infoValue pkginfo)

-- count*

-- create*

-- debugFunction(name, *args, **kwargs)

-- delete*

-- disable*

-- distRepo(tag, keys, **task_opts)

-- downloadTaskOutput(taskID, fileName, offset=0, size=-1, volume=None)

-- dropGroupMember(group, user)

-- echo(*args)

-- edit*

-- enable*

-- error

-- filterResults(methodName, *args, **kw)

-- findBuildID(X, strict=False)

-- freeTask(task_id)

-- | getAPIVersion()
getAPIVersion :: IO String
getAPIVersion = koji "getAPIVersion"

-- | getActiveRepos()
getActiveRepos :: IO Value
getActiveRepos = koji "getActiveRepos"

-- | getAllArches
getAllArches :: IO Value
getAllArches = koji "getAllArches"

-- | getAllPerms
getAllPerms :: IO [Struct]
getAllPerms = koji "getAllPerms"

-- | getArchive(archive_id, strict=False)
getArchive :: Int -> IO (Maybe Struct)
getArchive = fmap maybeStruct . koji "getArchive"

-- | getArchiveFile(archive_id, filename, strict=False)
getArchiveFile :: Int -> FilePath -> IO (Maybe Struct)
getArchiveFile archiveID file = maybeStruct <$> koji "getArchiveFile" archiveID file

-- | getArchiveType(filename=None, type_name=None, type_id=None, strict=False)
getArchiveType :: Maybe FilePath -> Maybe String -> Maybe Int -> IO Value
getArchiveType filename type_name type_id =
  koji "getArchiveType" (maybeString filename) (maybeString type_name) (maybeInt type_id)

-- | getArchiveTypes()
getArchiveTypes :: IO Value
getArchiveTypes = koji "getArchiveTypes"

-- | getAverageBuildDuration pkginfo
getAverageBuildDuration :: Info -> IO Value
getAverageBuildDuration = koji "getAverageBuildDuration" . infoValue

-- | getBuild(buildInfo, strict=False)
getBuild :: Info -- ^ buildID
         -> IO (Maybe Struct)
getBuild = fmap maybeStruct . koji "getBuild" . infoValue

-- | getBuildConfig tag
getBuildConfig :: String -> IO Value
getBuildConfig = koji "getBuildConfig"

-- | getBuildLogs build
getBuildLogs :: Info -- ^ buildinfo
             -> IO Value
getBuildLogs = koji "getBuildLogs" . infoValue

-- | getBuildTarget info
getBuildTarget :: String -> IO Value
getBuildTarget = koji "getBuildTarget"

-- | getBuildTargets info event buildTagID destTagID
getBuildTargets :: Maybe Info -> Maybe Int -> Maybe Int -> Maybe Int -> IO Value
getBuildTargets info event buildTagId destTagId  =
  koji "getBuildTargets" (maybeInfo info) (maybeInt event) (maybeInt buildTagId) (maybeInt destTagId)

-- | getBuildType buildinfo
getBuildType :: Info -- ^ buildinfo
             -> IO Value
getBuildType = koji "getBuildType" . infoValue

-- | getBuildroot buildrootId
getBuildroot :: Int -> IO Value
getBuildroot = koji "getBuildroot"

-- | getBuildrootListing buildrootId
getBuildrootListing :: Int -> IO Value
getBuildrootListing = koji "getBuildrootListing"

-- | getChangelogEntries(buildID=None, taskID=None, filepath=None, author=None, before=None, after=None, queryOpts=None)
getChangelogEntries :: Maybe Int -- ^ buildID
                    -> Maybe Int -- ^ taskID
                    -> Maybe FilePath
                    -> Maybe String -- ^ author
                    -> Maybe String -- ^ before
                    -> Maybe String -- ^ after
                    -> IO [Struct]
getChangelogEntries buildID taskID filepath author before after =
  koji "getChangelogEntries" (maybeInt buildID) (maybeInt taskID) (maybeString filepath) (maybeString author) (maybeString before) (maybeString after)

-- | getChannel channelinfo
getChannel :: Info -> IO Value
getChannel = koji "getChannel" . infoValue

-- | getEvent eventid
getEvent :: Int -> IO Struct
getEvent = koji "getEvent"

-- | getExternalRepo info
getExternalRepo :: Info -> Maybe Int -> IO Struct
getExternalRepo info event =
  koji "getExternalRepo" (infoValue info) () (maybeInt event)

-- | getExternalRepoList(tag_info, event=None)
getExternalRepoList :: Info -> Maybe Int -> IO [Struct]
getExternalRepoList info event =
  koji "getExternalRepoList" (infoValue info) (maybeInt event)

-- | getFullInheritance(tag, event=None, reverse=False, stops=None, jumps=None)
getFullInheritance :: String -> Maybe Int -> Bool -> IO Value
getFullInheritance tag event =
  koji "getFullInheritance" tag (maybeInt event)

-- | getGlobalInheritance(event=None)
getGlobalInheritance :: Maybe Int -> IO Value
getGlobalInheritance = koji "getGlobalInheritance" . maybeInt

-- | getGroupMembers(group)
getGroupMembers :: String -> IO Value
getGroupMembers = koji "getGroupMembers"

-- | getHost(hostInfo, strict=False, event=None)
getHost :: Info -> Maybe Int -> IO Struct
getHost info = koji "getHost" (infoValue info) () . maybeInt

-- | getImageArchive(archive_id, strict=False)
getImageArchive :: Int -> IO Struct
getImageArchive = koji "getImageArchive"

-- | getImageBuild(buildInfo, strict=False)
getImageBuild :: Info -> IO Struct
getImageBuild info = koji "getImageBuild" (infoValue info)

-- | getInheritanceData(tag, event=None)
getInheritanceData :: String -> Maybe Int -> IO Value
getInheritanceData tag event =
  koji "getInheritanceData" tag (maybeInt event)


-- | getLastEvent(before=None)
getLastEvent :: Maybe Int -> IO Value
getLastEvent = koji "getLastEvent" . maybeInt

-- | getLastHostUpdate(hostID)
getLastHostUpdate :: Int -> IO Value
getLastHostUpdate = koji "getLastHostUpdate"

-- | getLatestBuilds(tag, event=None, package=None, type=None)
--
-- List latest builds for tag (inheritance enabled)
getLatestBuilds :: Info -- ^ tag
                -> Maybe Int -- ^ event
                -> Maybe String -- ^ pkg
                -> Maybe String -- ^ type
                -> IO [Struct]
getLatestBuilds tag event pkg type_ =
  koji "getLatestBuilds" (infoValue tag) (maybeInt event) (maybeString pkg) (maybeString type_)

-- | getLatestMavenArchives(tag, event=None, inherit=True)
getLatestMavenArchives :: String -> Maybe Int -> Bool -> IO Value
getLatestMavenArchives tag event =
  koji "getLatestMavenArchives" tag (maybeInt event)

-- | getLatestRPMS(tag, package=None, arch=None, event=None, rpmsigs=False, type=None)
getLatestRPMS :: String -> Maybe String -> Maybe String -> Maybe Int -> Bool -> Maybe String -> IO Value
getLatestRPMS tag pkg arch event rpmsigs type_ =
  koji "getLatestRPMS" tag (maybeString pkg) (maybeString arch) (maybeInt event) rpmsigs (maybeString type_)

-- getLoggedInUser()

-- | getMavenArchive(archive_id, strict=False)
getMavenArchive :: Int -> IO Struct
getMavenArchive = koji "getMavenArchive"

-- | getMavenBuild(buildInfo, strict=False)
getMavenBuild :: Info -> IO Struct
getMavenBuild info = koji "getMavenBuild" (infoValue info)

-- | getNextRelease(build_info)
--
-- find the last successful or deleted build of this N-V.
-- If building is specified, skip also builds in progress
getNextRelease :: Info -> IO Value
getNextRelease info = koji "getNextRelease" (infoValue info)

-- | getPackage(info, strict=False, create=False)
--
-- Get the id,name for package
getPackage :: Info -> IO Value
getPackage info = koji "getPackage" (infoValue info)

-- | getPackageConfig(tag, pkg, event=None)
--
-- Get config for package in tag
getPackageConfig :: String -> String -> Maybe Int -> IO Value
getPackageConfig tag pkg event =
  koji "getPackageConfig" tag pkg (maybeInt event)

-- | getPackageID(name, strict=False)
--
-- Get package ID by name.
getPackageID :: String -> IO (Maybe Int)
getPackageID pkg = do
  res <- koji "getPackageID" pkg
  case res of
    ValueInt i -> return $ Just i
    _ -> return Nothing

-- | getRPM(rpminfo, strict=False, multi=False)
getRPM :: Info -> IO Struct
getRPM = koji "getRPM" . infoValue

-- | getRPMDeps(rpmID, depType=None, queryOpts=None, strict=False)
getRPMDeps :: Int -> Maybe String -> IO [Struct]
getRPMDeps rpmid deptype =
  koji "getRPMDeps" rpmid (maybeString deptype)

-- | getRPMFile(rpmID, filename, strict=False)
getRPMFile :: Int -> FilePath -> IO Struct
getRPMFile = koji "getRPMFile"

-- | getRPMHeaders(rpmID=None, taskID=None, filepath=None, headers=None)
getRPMHeaders :: Maybe Int -> Maybe Int -> Maybe FilePath -> Maybe Value -> IO Struct
getRPMHeaders rpmid taskid file headers =
  koji "getRPMHeaders" (maybeInt rpmid) (maybeInt taskid) (maybeString file) (fromMaybe ValueNil headers)

-- | getRepo(tag, state=None, event=None, dist=False)
getRepo :: String -> Maybe Int -> Maybe Int -> Bool -> IO Value
getRepo tag state event =
  koji "getRepo" tag (maybeInt state) (maybeInt event)

-- getSessionInfo()

-- | getTag(tagInfo, strict=False, event=None)
getTag :: Info -> Maybe Int -> IO Struct
getTag info = koji "getTag" (infoValue info) () . maybeInt

-- | getTagExternalRepos(tag_info=None, repo_info=None, event=None)
getTagExternalRepos :: Maybe Info -> Maybe Info -> Maybe Int -> IO Struct
getTagExternalRepos taginfo repoinfo event =
  koji "getTagExternalRepos" (maybeInfo taginfo) (maybeInfo repoinfo) (maybeInt event)

-- | getTagGroups(tag, event=None, inherit=True, incl_pkgs=True, incl_reqs=True, incl_blocked=False)
getTagGroups :: String -> Maybe Int -> Bool -> Bool -> Bool -> Bool -> IO Value
getTagGroups tag event =
  koji "getTagGroups" tag (maybeInt event)

-- | getTagID(info, strict=False, create=False)
getTagID :: Info -> IO Value
getTagID = koji "getTagID" . infoValue

-- | getTaskChildren(task_id, request=False, strict=False)
getTaskChildren :: Int -> Bool -> IO [Struct]
getTaskChildren = koji "getTaskChildren"

-- | getTaskDescendents(task_id, request=False)
getTaskDescendents :: Int -> Bool -> IO Struct
getTaskDescendents = koji "getTaskDescendents"

-- | getTaskInfo(task_id, request=False, strict=False)
getTaskInfo :: Int
            -> Bool -- ^ include request details
            -> IO (Maybe Struct)
getTaskInfo tid request = maybeStruct <$> koji "getTaskInfo" tid request
  -- res <- kojiCall "getTaskInfo" [show taskid]
  -- let state = res ^? key "state" % _Integer <&> (toEnum . fromInteger)
  --     arch = res ^? key "arch" % _String
  -- return $ TaskInfo arch state

-- | getTaskRequest(taskId)
getTaskRequest :: Int -> IO Value
getTaskRequest = koji "getTaskRequest"

-- | getTaskResult(taskId, raise_fault=True)
getTaskResult :: Int -> IO Value
getTaskResult = koji "getTaskResult"

-- | getUser(userInfo=None, strict=False, krb_princs=True)
getUser :: Info -> Bool -> IO (Maybe Struct)
getUser info krbprncpl =
  maybeStruct <$> koji "getUser" (infoValue info) () krbprncpl

-- | getUserPerms(userID=None)
getUserPerms :: Maybe Info -> IO Value
getUserPerms = koji "getUserPerms" . maybeInfo

-- | getVolume(volume, strict=False)
getVolume :: Info -> IO Value
getVolume = koji "getVolume" . infoValue

-- | getWinArchive(archive_id, strict=False)
getWinArchive :: Int -> IO Struct
getWinArchive = koji "getWinArchive"

-- | getWinBuild(buildInfo, strict=False)
getWinBuild :: Info -> IO (Maybe Struct)
getWinBuild = fmap maybeStruct . koji "getWinBuild" . infoValue

-- grantCGAccess(user, cg, create=False)

-- grantPermission(userinfo, permission, create=False)

-- groupListAdd(taginfo, grpinfo, block=False, force=False, **opts)

-- groupListBlock(taginfo, grpinfo)

-- groupListRemove(taginfo, grpinfo, force=False)

-- groupListUnblock(taginfo, grpinfo)

-- groupPackageListAdd(taginfo, grpinfo, pkg_name, block=False, force=False, **opts)

-- groupPackageListBlock(taginfo, grpinfo, pkg_name)

-- groupPackageListRemove(taginfo, grpinfo, pkg_name, force=False)

-- groupReqListUnblock(taginfo, grpinfo, reqinfo)

-- hasPerm(perm, strict=False)

hello :: IO String
hello = koji "hello"

-- host.* [skipped]

-- importArchive(filepath, buildinfo, type, typeInfo)

-- importRPM(path, basename)

-- krbLogin(*args, **opts)

-- | listArchiveFiles(archive_id, queryOpts=None, strict=False)
listArchiveFiles :: Int -> IO [Struct]
listArchiveFiles = koji "listArchiveFiles"

-- | listArchives(buildID=None, buildrootID=None, componentBuildrootID=None, hostID=None, type=None, filename=None, size=None, checksum=None, typeInfo=None, queryOpts=None, imageID=None, archiveID=None, strict=False)
listArchives :: Maybe Int -> Maybe Int -> Maybe Int -> Maybe Int -> Maybe String -> Maybe FilePath -> Maybe Int -> Maybe String -> Maybe Info -> Maybe Int -> Maybe Int -> IO [Struct]
listArchives buildID buildrootID componentBuildrootID hostID type_ file size checksum typeInfo imageID archiveID =
  koji "listArchives" (maybeInt buildID) (maybeInt buildrootID) (maybeInt componentBuildrootID) (maybeInt hostID) (maybeString type_) (maybeString file) (maybeInt size) (maybeString checksum) (maybeInfo typeInfo) () (maybeInt imageID) (maybeInt archiveID)

-- | listBTypes(query=None, queryOpts=None)
listBTypes :: Value -> IO Value
listBTypes = koji "listBTypes"

-- | listBuildRPMs(build)
listBuildRPMs :: Int -> IO [Struct]
listBuildRPMs = koji "listBuildRPMs"

-- | listBuildroots(hostID=None, tagID=None, state=None, rpmID=None, archiveID=None, taskID=None, buildrootID=None, queryOpts=None)
listBuildroots :: Maybe Int -> Maybe Int -> Maybe Int -> Maybe Int -> Maybe Int -> Maybe Int -> Maybe Int -> IO Value
listBuildroots hostID tagID state rpmID archiveID taskID buildrootID =
  koji "listBuildroots" (maybeInt hostID) (maybeInt tagID) (maybeInt state) (maybeInt rpmID) (maybeInt archiveID) (maybeInt taskID) (maybeInt buildrootID)

-- | listBuilds (packageID=None, userID=None, taskID=None, prefix=None, state=None, volumeID=None, source=None, createdBefore=None, createdAfter=None, completeBefore=None, completeAfter=None, type=None, typeInfo=None, queryOpts=None)
listBuilds :: Struct -> IO [Struct]
listBuilds args =
  let maybeArg fld = maybeValue (lookupStruct fld args) in
    koji "listBuilds" (maybeArg "packageID") (maybeArg "userID") (maybeArg "taskID") (maybeArg "prefix") (maybeArg "state") (maybeArg "volumeID") (maybeArg "source") (maybeArg "createdBefore") (maybeArg "createdAfter") (maybeArg "completeBefore") (maybeArg "completeAfter") (maybeArg "type") (maybeArg "typeInfo") (maybeArg "queryOpts")

-- | listCGs()
listCGs :: IO Struct
listCGs = koji "listCGs"

-- | listChannels(hostID=None, event=None)
listChannels :: Maybe Int -> Maybe Int -> IO Value
listChannels hostID event =
  koji "listChannels" (maybeInt hostID) (maybeInt event)

-- | listExternalRepos(info=None, url=None, event=None, queryOpts=None)
listExternalRepos :: Maybe Info -> Maybe String -> Maybe Int -> IO Value
listExternalRepos info url event =
  koji "listExternalRepos" (maybeInfo info) (maybeString url) (maybeInt event)

-- | listHosts(arches=None, channelID=None, ready=None, enabled=None, userID=None, queryOpts=None)
listHosts :: Maybe Value -> Maybe Int -> Bool -> Bool -> Maybe Int -> IO Value
listHosts arches channelID ready enabled userID =
  koji "listHosts" (maybeValue arches) (maybeInt channelID) ready enabled (maybeInt userID)

-- | listPackages(tagID=None, userID=None, pkgID=None, prefix=None, inherited=False, with_dups=False, event=None, queryOpts=None)
listPackages :: Maybe Int -> Maybe Int -> Maybe Int -> Maybe String -> Bool -> Bool -> Maybe Int -> IO [Struct]
listPackages tagID userID pkgID prefix inherited with_dups event =
  koji "listPackages" (maybeInt tagID) (maybeInt userID) (maybeInt pkgID) (maybeString prefix) inherited with_dups (maybeInt event)

-- | listPackagesSimple prefix
listPackagesSimple :: String -- ^ package name search prefix
                   -> IO [Struct]
listPackagesSimple = koji "listPackagesSimple"

-- | listRPMFiles(rpmID, queryOpts=None)
listRPMFiles :: Int -> IO [Struct]
listRPMFiles = koji "listRPMFiles"

-- | listRPMs(buildID=None, buildrootID=None, imageID=None, componentBuildrootID=None, hostID=None, arches=None, queryOpts=None)
listRPMs :: Maybe Int -> Maybe Int -> Maybe Int -> Maybe Int -> Maybe Int -> Maybe Value -> IO [Struct]
listRPMs buildID buildrootID imageID componentBuildrootID hostID arches =
  koji "listRPMs" (maybeInt buildID) (maybeInt buildrootID) (maybeInt imageID) (maybeInt componentBuildrootID) (maybeInt hostID) (maybeValue arches)

-- | listSideTags(basetag=None, user=None, queryOpts=None)
listSideTags :: Maybe Info -> Maybe Info -> IO Value
listSideTags basetag user =
  koji "listSideTags" (maybeInfo basetag) (maybeInfo user)

-- | listTagged(tag, event=None, inherit=False, prefix=None, latest=False, package=None, owner=None, type=None)
listTagged :: String -> Maybe Int -> Bool -> Maybe String -> Bool -> Maybe String -> Maybe String -> Maybe String -> IO Value
listTagged tag event inherit prefix latest package owner type_ =
  koji "listTagged" tag (maybeInt event) inherit (maybeString prefix) latest (maybeString package) (maybeString owner) (maybeString type_)

-- | listTaggedArchives(tag, event=None, inherit=False, latest=False, package=None, type=None)
listTaggedArchives :: String -> Maybe Int -> Bool -> Bool -> Maybe String -> Maybe String -> IO Value
listTaggedArchives tag event inherit latest package type_ =
  koji "listTaggedArchives" tag (maybeInt event) inherit latest (maybeString package) (maybeString type_)

-- | listTaggedRPMS(tag, event=None, inherit=False, latest=False, package=None, arch=None, rpmsigs=False, owner=None, type=None)
listTaggedRPMS :: String -> Maybe Int -> Bool -> Bool -> Maybe String ->  Maybe String -> Bool -> Maybe String -> Maybe String -> IO Value
listTaggedRPMS tag event inherit latest package arch rpmsigs owner type_ =
  koji "listTaggedRPMS" tag (maybeInt event) inherit latest (maybeString package) (maybeString arch) rpmsigs (maybeString owner) (maybeString type_)

-- | listTags(build=None, package=None, perms=True, queryOpts=None)
listTags :: Maybe Info -> Maybe Info -> Bool -> IO [Struct]
listTags build package =
  koji "listTags" (maybeInfo build) (maybeInfo package)

-- | listTaskOutput(taskID, stat=False, all_volumes=False, strict=False)
listTaskOutput :: Int -> Bool -> Bool -> Bool -> IO Struct
listTaskOutput = koji "listTaskOutput"

-- | listTasks(opts=None, queryOpts=None)
listTasks :: Struct -- ^ opts
          -> Struct -- ^ qopts
          -> IO [Struct]
listTasks = koji "listTasks"

-- | listUsers(userType=0, prefix=None, queryOpts=None)
listUsers :: Maybe Int -> Maybe String -> IO [Struct]
listUsers userType prefix =
  koji "listUsers" (maybeInt userType) (maybeString prefix)

-- | listVolumes()
listVolumes :: IO Value
listVolumes = koji "listVolumes"

-- login(*args, **opts)

-- logout()

-- logoutChild(session_id)

-- makeTask(*args, **opts)

-- mavenBuild(url, target, opts=None, priority=None, channel='maven')

-- mavenEnabled()

-- mergeScratch(task_id)

-- moveAllBuilds(tag1, tag2, package, force=False)

-- moveBuild(tag1, tag2, build, force=False)

-- newGroup(name)

-- newRepo(tag, event=None, src=False, debuginfo=False, separate_src=False)

-- packageListAdd(taginfo, pkginfo, owner=None, block=None, extra_arches=None, force=False, update=False)

-- packageListBlock(taginfo, pkginfo, force=False)

-- packageListRemove(taginfo, pkginfo, force=False)

-- packageListSetArches(taginfo, pkginfo, arches, force=False)

-- packageListSetOwner(taginfo, pkginfo, owner, force=False)

-- packageListUnblock(taginfo, pkginfo, force=False)

-- queryHistory(tables=None, **kwargs)

-- queryRPMSigs(rpm_id=None, sigkey=None, queryOpts=None)

-- remove*

-- repo*

-- | repoInfo(repo_id, strict=False)
repoInfo :: Int -> IO Value
repoInfo = koji "repoInfo"

-- resetBuild(build)

-- restartHosts(priority=5, options=None)

-- | resubmitTask(taskID)
resubmitTask :: Int -> IO Value
resubmitTask = koji "resubmitTask"

-- revoke*

-- runroot(tagInfo, arch, command, channel=None, **opts)

-- search(terms, type, matchType, queryOpts=None)

-- set*

-- sharedSession()

-- showOpts()

-- showSession()

-- sslLogin(*args, **opts)

-- subsession()

-- system.*

-- tagBuild(tag, build, force=False, fromtag=None)

-- tagBuildBypass(tag, build, force=False, notify=True)

-- | tagChangedSinceEvent(event, taglist)
tagChangedSinceEvent :: Int -> Value -> IO Bool
tagChangedSinceEvent = koji "tagChangedSinceEvent"

-- | tagHistory(build=None, tag=None, package=None, active=None, queryOpts=None)
tagHistory :: Maybe Info -> Maybe Info -> Maybe Info -> Bool -> IO Value
tagHistory build tag package =
  koji "tagHistory" (maybeInfo build) (maybeInfo tag) (maybeInfo package)

-- | taskFinished(taskId)
taskFinished :: Int -> IO Bool
taskFinished = koji "taskFinished"

-- | taskReport(owner=None)
taskReport :: Maybe String -> IO Value
taskReport = koji "taskReport" . maybeString

-- untag*

-- updateNotification(id, package_id, tag_id, success_only)

-- uploadFile(path, name, size, md5sum, offset, data, volume=None)

-- winBuild(vm, url, target, opts=None, priority=None, channel='vm')

-- winEnabled()

-- wrapperRPM(build, url, target, priority=None, channel='maven', opts=None)

-- writeSignedRPM(an_rpm, sigkey, force=False)


-- readStructString :: String -> Struct -> String
-- readStructString key str =
--   case lookup key str of
--     Just (ValueString s) -> s
--     _ -> error $ "No String for " ++ key

-- readStructArray :: String -> Struct -> Maybe [Value]
-- readStructArray key struct =
--   either error id <$> runExceptT (getField key struct)
-- --    Just (ValueArray s) -> s
-- --    _ -> error $ "No Array for " ++ key

-- readMethodParams :: String -> Maybe [Value]
-- readMethodParams s =
--   either error params <$> runExceptT (parseCall s)
--   where
--     params (MethodCall _m str) = str

lookupStruct :: XmlRpcType a => String -> Struct -> Maybe a
lookupStruct key struct =
  either error id <$> runExceptT (getField key struct)

maybeVal :: String -> Maybe a -> a
maybeVal err = fromMaybe (error err)

getValue :: XmlRpcType a => Value -> Maybe a
getValue = fmap (either error id) . runExceptT . fromValue
