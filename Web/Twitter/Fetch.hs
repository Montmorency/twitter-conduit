{-# LANGUAGE OverloadedStrings #-}

module Web.Twitter.Fetch (
  -- * Search
  -- , search
  
  -- * Direct Messages
  -- , directMessages
  -- , directMessagesSent
  -- , directMessagesShowId
    
  -- * Friends & Followers
  friendsIds,
  followersIds,
  -- , friendshipsExists
  -- , friendshipsIncoming
  -- , friendshipsOutgoing
  -- , friendshipsShow
  -- , friendshipsLookup
  -- , friendshipsNoRetweetIds

  -- * Users
  -- , usersLookup
  -- , usersProfileImageScreenName
  -- , usersSearch
  usersShow,
  -- , usersContributees
  -- , usersContributors
  
  -- * Suggested Users
  -- , usersSuggestions
  -- , usersSuggestionsSlug
  -- , usersSuggestionsSlugMembers
  
  -- * Favorites
  -- , favorites
  
  -- * Lists
  listsAll,
  -- , listsStatuses
  -- , listsMemberships
  -- , listsSubscribers
  -- , listsSubscribersShow
  -- , listsMembersShow
  listsMembers,
  -- , lists
  -- , listsShow
  -- , listsSubscriptions
  ) where

import Data.Aeson hiding (Error)
import qualified Data.Conduit as C
import qualified Data.ByteString.Char8 as B8
import qualified Network.HTTP.Types as HT

import Web.Twitter.Types
import Web.Twitter.Monad
import Web.Twitter.Utils
import Web.Twitter.Query
import Web.Twitter.Api

mkQueryUser :: QueryUser -> HT.Query
mkQueryUser (QUserId uid) =  [("user_id", Just $ showBS uid)]
mkQueryUser (QScreenName sn) = [("screen_name", Just . B8.pack $ sn)]

mkQueryList :: QueryList -> HT.Query
mkQueryList (QListId lid) =  [("list_id", Just $ showBS lid)]
mkQueryList (QListName listname) =
  [("slug", Just . B8.pack $ lstName),
   ("owner_screen_name", Just . B8.pack $ screenName)]
  where
    (screenName, ln) = span (/= '/') listname
    lstName = drop 1 ln

friendsIds, followersIds :: QueryUser -> C.ResourceT TW (C.Source TW UserId)
friendsIds   q = apiCursor "friends/ids.json"   (mkQueryUser q) "ids"
followersIds q = apiCursor "followers/ids.json" (mkQueryUser q) "ids"

usersShow :: QueryUser -> TW User
usersShow q = apiGet "users/show.json" (mkQueryUser q)

listsAll :: QueryUser -> C.ResourceT TW (C.Source TW List)
listsAll q = apiCursor "lists/all.json" (mkQueryUser q) ""

listsMembers :: QueryList -> C.ResourceT TW (C.Source TW User)
listsMembers q = apiCursor "lists/members.json" (mkQueryList q) "users"
