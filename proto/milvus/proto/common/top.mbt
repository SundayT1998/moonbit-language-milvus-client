///|
pub(all) enum IndexState {
  IndexStateNone
  Unissued
  InProgress
  Finished
  Failed
  Retry
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn IndexState::to_enum(self : IndexState) -> @lib.Enum {
  match self {
    IndexState::IndexStateNone => 0
    IndexState::Unissued => 1
    IndexState::InProgress => 2
    IndexState::Finished => 3
    IndexState::Failed => 4
    IndexState::Retry => 5
    IndexState::Unknown(value) => value
  }
}

///|
pub fn IndexState::from_enum(i : @lib.Enum) -> IndexState {
  match i.0 {
    0 => IndexState::IndexStateNone
    1 => IndexState::Unissued
    2 => IndexState::InProgress
    3 => IndexState::Finished
    4 => IndexState::Failed
    5 => IndexState::Retry
    _ => IndexState::Unknown(i)
  }
}

///|
pub impl Default for IndexState with fn default() -> IndexState {
  IndexState::IndexStateNone
}

///|
pub impl @lib.Sized for IndexState with fn size_of(self : IndexState) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for IndexState with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> IndexState raise {
  match json {
    String("IndexStateNone") => IndexState::IndexStateNone
    String("Unissued") => IndexState::Unissued
    String("InProgress") => IndexState::InProgress
    String("Finished") => IndexState::Finished
    String("Failed") => IndexState::Failed
    String("Retry") => IndexState::Retry
    Number(0, ..) => IndexState::IndexStateNone
    Number(1, ..) => IndexState::Unissued
    Number(2, ..) => IndexState::InProgress
    Number(3, ..) => IndexState::Finished
    Number(4, ..) => IndexState::Failed
    Number(5, ..) => IndexState::Retry
    Number(value, ..) =>
      if value.trunc() == value {
        IndexState::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for IndexState with fn to_json(self : IndexState) -> Json {
  match self {
    IndexState::IndexStateNone => "IndexStateNone"
    IndexState::Unissued => "Unissued"
    IndexState::InProgress => "InProgress"
    IndexState::Finished => "Finished"
    IndexState::Failed => "Failed"
    IndexState::Retry => "Retry"
    IndexState::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) enum LoadState {
  LoadStateNotExist
  LoadStateNotLoad
  LoadStateLoading
  LoadStateLoaded
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn LoadState::to_enum(self : LoadState) -> @lib.Enum {
  match self {
    LoadState::LoadStateNotExist => 0
    LoadState::LoadStateNotLoad => 1
    LoadState::LoadStateLoading => 2
    LoadState::LoadStateLoaded => 3
    LoadState::Unknown(value) => value
  }
}

///|
pub fn LoadState::from_enum(i : @lib.Enum) -> LoadState {
  match i.0 {
    0 => LoadState::LoadStateNotExist
    1 => LoadState::LoadStateNotLoad
    2 => LoadState::LoadStateLoading
    3 => LoadState::LoadStateLoaded
    _ => LoadState::Unknown(i)
  }
}

///|
pub impl Default for LoadState with fn default() -> LoadState {
  LoadState::LoadStateNotExist
}

///|
pub impl @lib.Sized for LoadState with fn size_of(self : LoadState) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for LoadState with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> LoadState raise {
  match json {
    String("LoadStateNotExist") => LoadState::LoadStateNotExist
    String("LoadStateNotLoad") => LoadState::LoadStateNotLoad
    String("LoadStateLoading") => LoadState::LoadStateLoading
    String("LoadStateLoaded") => LoadState::LoadStateLoaded
    Number(0, ..) => LoadState::LoadStateNotExist
    Number(1, ..) => LoadState::LoadStateNotLoad
    Number(2, ..) => LoadState::LoadStateLoading
    Number(3, ..) => LoadState::LoadStateLoaded
    Number(value, ..) =>
      if value.trunc() == value {
        LoadState::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for LoadState with fn to_json(self : LoadState) -> Json {
  match self {
    LoadState::LoadStateNotExist => "LoadStateNotExist"
    LoadState::LoadStateNotLoad => "LoadStateNotLoad"
    LoadState::LoadStateLoading => "LoadStateLoading"
    LoadState::LoadStateLoaded => "LoadStateLoaded"
    LoadState::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) enum ConsistencyLevel {
  Strong
  Session
  Bounded
  Eventually
  Customized
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn ConsistencyLevel::to_enum(self : ConsistencyLevel) -> @lib.Enum {
  match self {
    ConsistencyLevel::Strong => 0
    ConsistencyLevel::Session => 1
    ConsistencyLevel::Bounded => 2
    ConsistencyLevel::Eventually => 3
    ConsistencyLevel::Customized => 4
    ConsistencyLevel::Unknown(value) => value
  }
}

///|
pub fn ConsistencyLevel::from_enum(i : @lib.Enum) -> ConsistencyLevel {
  match i.0 {
    0 => ConsistencyLevel::Strong
    1 => ConsistencyLevel::Session
    2 => ConsistencyLevel::Bounded
    3 => ConsistencyLevel::Eventually
    4 => ConsistencyLevel::Customized
    _ => ConsistencyLevel::Unknown(i)
  }
}

///|
pub impl Default for ConsistencyLevel with fn default() -> ConsistencyLevel {
  ConsistencyLevel::Strong
}

///|
pub impl @lib.Sized for ConsistencyLevel with fn size_of(
  self : ConsistencyLevel,
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for ConsistencyLevel with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ConsistencyLevel raise {
  match json {
    String("Strong") => ConsistencyLevel::Strong
    String("Session") => ConsistencyLevel::Session
    String("Bounded") => ConsistencyLevel::Bounded
    String("Eventually") => ConsistencyLevel::Eventually
    String("Customized") => ConsistencyLevel::Customized
    Number(0, ..) => ConsistencyLevel::Strong
    Number(1, ..) => ConsistencyLevel::Session
    Number(2, ..) => ConsistencyLevel::Bounded
    Number(3, ..) => ConsistencyLevel::Eventually
    Number(4, ..) => ConsistencyLevel::Customized
    Number(value, ..) =>
      if value.trunc() == value {
        ConsistencyLevel::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for ConsistencyLevel with fn to_json(self : ConsistencyLevel) -> Json {
  match self {
    ConsistencyLevel::Strong => "Strong"
    ConsistencyLevel::Session => "Session"
    ConsistencyLevel::Bounded => "Bounded"
    ConsistencyLevel::Eventually => "Eventually"
    ConsistencyLevel::Customized => "Customized"
    ConsistencyLevel::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) enum ErrorCode {
  Success
  UnexpectedError
  ConnectFailed
  PermissionDenied
  CollectionNotExists
  IllegalArgument
  IllegalDimension
  IllegalIndexType
  IllegalCollectionName
  IllegalTOPK
  IllegalRowRecord
  IllegalVectorID
  IllegalSearchResult
  FileNotFound
  MetaFailed
  CacheFailed
  CannotCreateFolder
  CannotCreateFile
  CannotDeleteFolder
  CannotDeleteFile
  BuildIndexError
  IllegalNLIST
  IllegalMetricType
  OutOfMemory
  IndexNotExist
  EmptyCollection
  UpdateImportTaskFailure
  CollectionNameNotFound
  CreateCredentialFailure
  UpdateCredentialFailure
  DeleteCredentialFailure
  GetCredentialFailure
  ListCredUsersFailure
  GetUserFailure
  CreateRoleFailure
  DropRoleFailure
  OperateUserRoleFailure
  SelectRoleFailure
  SelectUserFailure
  SelectResourceFailure
  OperatePrivilegeFailure
  SelectGrantFailure
  RefreshPolicyInfoCacheFailure
  ListPolicyFailure
  NotShardLeader
  NoReplicaAvailable
  SegmentNotFound
  ForceDeny
  RateLimit
  NodeIDNotMatch
  UpsertAutoIDTrue
  InsufficientMemoryToLoad
  MemoryQuotaExhausted
  DiskQuotaExhausted
  TimeTickLongDelay
  NotReadyServe
  NotReadyCoordActivating
  CreatePrivilegeGroupFailure
  DropPrivilegeGroupFailure
  ListPrivilegeGroupsFailure
  OperatePrivilegeGroupFailure
  SchemaMismatch
  DataCoordNA
  DDRequestRace
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn ErrorCode::to_enum(self : ErrorCode) -> @lib.Enum {
  match self {
    ErrorCode::Success => 0
    ErrorCode::UnexpectedError => 1
    ErrorCode::ConnectFailed => 2
    ErrorCode::PermissionDenied => 3
    ErrorCode::CollectionNotExists => 4
    ErrorCode::IllegalArgument => 5
    ErrorCode::IllegalDimension => 7
    ErrorCode::IllegalIndexType => 8
    ErrorCode::IllegalCollectionName => 9
    ErrorCode::IllegalTOPK => 10
    ErrorCode::IllegalRowRecord => 11
    ErrorCode::IllegalVectorID => 12
    ErrorCode::IllegalSearchResult => 13
    ErrorCode::FileNotFound => 14
    ErrorCode::MetaFailed => 15
    ErrorCode::CacheFailed => 16
    ErrorCode::CannotCreateFolder => 17
    ErrorCode::CannotCreateFile => 18
    ErrorCode::CannotDeleteFolder => 19
    ErrorCode::CannotDeleteFile => 20
    ErrorCode::BuildIndexError => 21
    ErrorCode::IllegalNLIST => 22
    ErrorCode::IllegalMetricType => 23
    ErrorCode::OutOfMemory => 24
    ErrorCode::IndexNotExist => 25
    ErrorCode::EmptyCollection => 26
    ErrorCode::UpdateImportTaskFailure => 27
    ErrorCode::CollectionNameNotFound => 28
    ErrorCode::CreateCredentialFailure => 29
    ErrorCode::UpdateCredentialFailure => 30
    ErrorCode::DeleteCredentialFailure => 31
    ErrorCode::GetCredentialFailure => 32
    ErrorCode::ListCredUsersFailure => 33
    ErrorCode::GetUserFailure => 34
    ErrorCode::CreateRoleFailure => 35
    ErrorCode::DropRoleFailure => 36
    ErrorCode::OperateUserRoleFailure => 37
    ErrorCode::SelectRoleFailure => 38
    ErrorCode::SelectUserFailure => 39
    ErrorCode::SelectResourceFailure => 40
    ErrorCode::OperatePrivilegeFailure => 41
    ErrorCode::SelectGrantFailure => 42
    ErrorCode::RefreshPolicyInfoCacheFailure => 43
    ErrorCode::ListPolicyFailure => 44
    ErrorCode::NotShardLeader => 45
    ErrorCode::NoReplicaAvailable => 46
    ErrorCode::SegmentNotFound => 47
    ErrorCode::ForceDeny => 48
    ErrorCode::RateLimit => 49
    ErrorCode::NodeIDNotMatch => 50
    ErrorCode::UpsertAutoIDTrue => 51
    ErrorCode::InsufficientMemoryToLoad => 52
    ErrorCode::MemoryQuotaExhausted => 53
    ErrorCode::DiskQuotaExhausted => 54
    ErrorCode::TimeTickLongDelay => 55
    ErrorCode::NotReadyServe => 56
    ErrorCode::NotReadyCoordActivating => 57
    ErrorCode::CreatePrivilegeGroupFailure => 58
    ErrorCode::DropPrivilegeGroupFailure => 59
    ErrorCode::ListPrivilegeGroupsFailure => 60
    ErrorCode::OperatePrivilegeGroupFailure => 61
    ErrorCode::SchemaMismatch => 62
    ErrorCode::DataCoordNA => 100
    ErrorCode::DDRequestRace => 1000
    ErrorCode::Unknown(value) => value
  }
}

///|
pub fn ErrorCode::from_enum(i : @lib.Enum) -> ErrorCode {
  match i.0 {
    0 => ErrorCode::Success
    1 => ErrorCode::UnexpectedError
    2 => ErrorCode::ConnectFailed
    3 => ErrorCode::PermissionDenied
    4 => ErrorCode::CollectionNotExists
    5 => ErrorCode::IllegalArgument
    7 => ErrorCode::IllegalDimension
    8 => ErrorCode::IllegalIndexType
    9 => ErrorCode::IllegalCollectionName
    10 => ErrorCode::IllegalTOPK
    11 => ErrorCode::IllegalRowRecord
    12 => ErrorCode::IllegalVectorID
    13 => ErrorCode::IllegalSearchResult
    14 => ErrorCode::FileNotFound
    15 => ErrorCode::MetaFailed
    16 => ErrorCode::CacheFailed
    17 => ErrorCode::CannotCreateFolder
    18 => ErrorCode::CannotCreateFile
    19 => ErrorCode::CannotDeleteFolder
    20 => ErrorCode::CannotDeleteFile
    21 => ErrorCode::BuildIndexError
    22 => ErrorCode::IllegalNLIST
    23 => ErrorCode::IllegalMetricType
    24 => ErrorCode::OutOfMemory
    25 => ErrorCode::IndexNotExist
    26 => ErrorCode::EmptyCollection
    27 => ErrorCode::UpdateImportTaskFailure
    28 => ErrorCode::CollectionNameNotFound
    29 => ErrorCode::CreateCredentialFailure
    30 => ErrorCode::UpdateCredentialFailure
    31 => ErrorCode::DeleteCredentialFailure
    32 => ErrorCode::GetCredentialFailure
    33 => ErrorCode::ListCredUsersFailure
    34 => ErrorCode::GetUserFailure
    35 => ErrorCode::CreateRoleFailure
    36 => ErrorCode::DropRoleFailure
    37 => ErrorCode::OperateUserRoleFailure
    38 => ErrorCode::SelectRoleFailure
    39 => ErrorCode::SelectUserFailure
    40 => ErrorCode::SelectResourceFailure
    41 => ErrorCode::OperatePrivilegeFailure
    42 => ErrorCode::SelectGrantFailure
    43 => ErrorCode::RefreshPolicyInfoCacheFailure
    44 => ErrorCode::ListPolicyFailure
    45 => ErrorCode::NotShardLeader
    46 => ErrorCode::NoReplicaAvailable
    47 => ErrorCode::SegmentNotFound
    48 => ErrorCode::ForceDeny
    49 => ErrorCode::RateLimit
    50 => ErrorCode::NodeIDNotMatch
    51 => ErrorCode::UpsertAutoIDTrue
    52 => ErrorCode::InsufficientMemoryToLoad
    53 => ErrorCode::MemoryQuotaExhausted
    54 => ErrorCode::DiskQuotaExhausted
    55 => ErrorCode::TimeTickLongDelay
    56 => ErrorCode::NotReadyServe
    57 => ErrorCode::NotReadyCoordActivating
    58 => ErrorCode::CreatePrivilegeGroupFailure
    59 => ErrorCode::DropPrivilegeGroupFailure
    60 => ErrorCode::ListPrivilegeGroupsFailure
    61 => ErrorCode::OperatePrivilegeGroupFailure
    62 => ErrorCode::SchemaMismatch
    100 => ErrorCode::DataCoordNA
    1000 => ErrorCode::DDRequestRace
    _ => ErrorCode::Unknown(i)
  }
}

///|
pub impl Default for ErrorCode with fn default() -> ErrorCode {
  ErrorCode::Success
}

///|
pub impl @lib.Sized for ErrorCode with fn size_of(self : ErrorCode) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for ErrorCode with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ErrorCode raise {
  match json {
    String("Success") => ErrorCode::Success
    String("UnexpectedError") => ErrorCode::UnexpectedError
    String("ConnectFailed") => ErrorCode::ConnectFailed
    String("PermissionDenied") => ErrorCode::PermissionDenied
    String("CollectionNotExists") => ErrorCode::CollectionNotExists
    String("IllegalArgument") => ErrorCode::IllegalArgument
    String("IllegalDimension") => ErrorCode::IllegalDimension
    String("IllegalIndexType") => ErrorCode::IllegalIndexType
    String("IllegalCollectionName") => ErrorCode::IllegalCollectionName
    String("IllegalTOPK") => ErrorCode::IllegalTOPK
    String("IllegalRowRecord") => ErrorCode::IllegalRowRecord
    String("IllegalVectorID") => ErrorCode::IllegalVectorID
    String("IllegalSearchResult") => ErrorCode::IllegalSearchResult
    String("FileNotFound") => ErrorCode::FileNotFound
    String("MetaFailed") => ErrorCode::MetaFailed
    String("CacheFailed") => ErrorCode::CacheFailed
    String("CannotCreateFolder") => ErrorCode::CannotCreateFolder
    String("CannotCreateFile") => ErrorCode::CannotCreateFile
    String("CannotDeleteFolder") => ErrorCode::CannotDeleteFolder
    String("CannotDeleteFile") => ErrorCode::CannotDeleteFile
    String("BuildIndexError") => ErrorCode::BuildIndexError
    String("IllegalNLIST") => ErrorCode::IllegalNLIST
    String("IllegalMetricType") => ErrorCode::IllegalMetricType
    String("OutOfMemory") => ErrorCode::OutOfMemory
    String("IndexNotExist") => ErrorCode::IndexNotExist
    String("EmptyCollection") => ErrorCode::EmptyCollection
    String("UpdateImportTaskFailure") => ErrorCode::UpdateImportTaskFailure
    String("CollectionNameNotFound") => ErrorCode::CollectionNameNotFound
    String("CreateCredentialFailure") => ErrorCode::CreateCredentialFailure
    String("UpdateCredentialFailure") => ErrorCode::UpdateCredentialFailure
    String("DeleteCredentialFailure") => ErrorCode::DeleteCredentialFailure
    String("GetCredentialFailure") => ErrorCode::GetCredentialFailure
    String("ListCredUsersFailure") => ErrorCode::ListCredUsersFailure
    String("GetUserFailure") => ErrorCode::GetUserFailure
    String("CreateRoleFailure") => ErrorCode::CreateRoleFailure
    String("DropRoleFailure") => ErrorCode::DropRoleFailure
    String("OperateUserRoleFailure") => ErrorCode::OperateUserRoleFailure
    String("SelectRoleFailure") => ErrorCode::SelectRoleFailure
    String("SelectUserFailure") => ErrorCode::SelectUserFailure
    String("SelectResourceFailure") => ErrorCode::SelectResourceFailure
    String("OperatePrivilegeFailure") => ErrorCode::OperatePrivilegeFailure
    String("SelectGrantFailure") => ErrorCode::SelectGrantFailure
    String("RefreshPolicyInfoCacheFailure") =>
      ErrorCode::RefreshPolicyInfoCacheFailure
    String("ListPolicyFailure") => ErrorCode::ListPolicyFailure
    String("NotShardLeader") => ErrorCode::NotShardLeader
    String("NoReplicaAvailable") => ErrorCode::NoReplicaAvailable
    String("SegmentNotFound") => ErrorCode::SegmentNotFound
    String("ForceDeny") => ErrorCode::ForceDeny
    String("RateLimit") => ErrorCode::RateLimit
    String("NodeIDNotMatch") => ErrorCode::NodeIDNotMatch
    String("UpsertAutoIDTrue") => ErrorCode::UpsertAutoIDTrue
    String("InsufficientMemoryToLoad") => ErrorCode::InsufficientMemoryToLoad
    String("MemoryQuotaExhausted") => ErrorCode::MemoryQuotaExhausted
    String("DiskQuotaExhausted") => ErrorCode::DiskQuotaExhausted
    String("TimeTickLongDelay") => ErrorCode::TimeTickLongDelay
    String("NotReadyServe") => ErrorCode::NotReadyServe
    String("NotReadyCoordActivating") => ErrorCode::NotReadyCoordActivating
    String("CreatePrivilegeGroupFailure") =>
      ErrorCode::CreatePrivilegeGroupFailure
    String("DropPrivilegeGroupFailure") => ErrorCode::DropPrivilegeGroupFailure
    String("ListPrivilegeGroupsFailure") =>
      ErrorCode::ListPrivilegeGroupsFailure
    String("OperatePrivilegeGroupFailure") =>
      ErrorCode::OperatePrivilegeGroupFailure
    String("SchemaMismatch") => ErrorCode::SchemaMismatch
    String("DataCoordNA") => ErrorCode::DataCoordNA
    String("DDRequestRace") => ErrorCode::DDRequestRace
    Number(0, ..) => ErrorCode::Success
    Number(1, ..) => ErrorCode::UnexpectedError
    Number(2, ..) => ErrorCode::ConnectFailed
    Number(3, ..) => ErrorCode::PermissionDenied
    Number(4, ..) => ErrorCode::CollectionNotExists
    Number(5, ..) => ErrorCode::IllegalArgument
    Number(7, ..) => ErrorCode::IllegalDimension
    Number(8, ..) => ErrorCode::IllegalIndexType
    Number(9, ..) => ErrorCode::IllegalCollectionName
    Number(10, ..) => ErrorCode::IllegalTOPK
    Number(11, ..) => ErrorCode::IllegalRowRecord
    Number(12, ..) => ErrorCode::IllegalVectorID
    Number(13, ..) => ErrorCode::IllegalSearchResult
    Number(14, ..) => ErrorCode::FileNotFound
    Number(15, ..) => ErrorCode::MetaFailed
    Number(16, ..) => ErrorCode::CacheFailed
    Number(17, ..) => ErrorCode::CannotCreateFolder
    Number(18, ..) => ErrorCode::CannotCreateFile
    Number(19, ..) => ErrorCode::CannotDeleteFolder
    Number(20, ..) => ErrorCode::CannotDeleteFile
    Number(21, ..) => ErrorCode::BuildIndexError
    Number(22, ..) => ErrorCode::IllegalNLIST
    Number(23, ..) => ErrorCode::IllegalMetricType
    Number(24, ..) => ErrorCode::OutOfMemory
    Number(25, ..) => ErrorCode::IndexNotExist
    Number(26, ..) => ErrorCode::EmptyCollection
    Number(27, ..) => ErrorCode::UpdateImportTaskFailure
    Number(28, ..) => ErrorCode::CollectionNameNotFound
    Number(29, ..) => ErrorCode::CreateCredentialFailure
    Number(30, ..) => ErrorCode::UpdateCredentialFailure
    Number(31, ..) => ErrorCode::DeleteCredentialFailure
    Number(32, ..) => ErrorCode::GetCredentialFailure
    Number(33, ..) => ErrorCode::ListCredUsersFailure
    Number(34, ..) => ErrorCode::GetUserFailure
    Number(35, ..) => ErrorCode::CreateRoleFailure
    Number(36, ..) => ErrorCode::DropRoleFailure
    Number(37, ..) => ErrorCode::OperateUserRoleFailure
    Number(38, ..) => ErrorCode::SelectRoleFailure
    Number(39, ..) => ErrorCode::SelectUserFailure
    Number(40, ..) => ErrorCode::SelectResourceFailure
    Number(41, ..) => ErrorCode::OperatePrivilegeFailure
    Number(42, ..) => ErrorCode::SelectGrantFailure
    Number(43, ..) => ErrorCode::RefreshPolicyInfoCacheFailure
    Number(44, ..) => ErrorCode::ListPolicyFailure
    Number(45, ..) => ErrorCode::NotShardLeader
    Number(46, ..) => ErrorCode::NoReplicaAvailable
    Number(47, ..) => ErrorCode::SegmentNotFound
    Number(48, ..) => ErrorCode::ForceDeny
    Number(49, ..) => ErrorCode::RateLimit
    Number(50, ..) => ErrorCode::NodeIDNotMatch
    Number(51, ..) => ErrorCode::UpsertAutoIDTrue
    Number(52, ..) => ErrorCode::InsufficientMemoryToLoad
    Number(53, ..) => ErrorCode::MemoryQuotaExhausted
    Number(54, ..) => ErrorCode::DiskQuotaExhausted
    Number(55, ..) => ErrorCode::TimeTickLongDelay
    Number(56, ..) => ErrorCode::NotReadyServe
    Number(57, ..) => ErrorCode::NotReadyCoordActivating
    Number(58, ..) => ErrorCode::CreatePrivilegeGroupFailure
    Number(59, ..) => ErrorCode::DropPrivilegeGroupFailure
    Number(60, ..) => ErrorCode::ListPrivilegeGroupsFailure
    Number(61, ..) => ErrorCode::OperatePrivilegeGroupFailure
    Number(62, ..) => ErrorCode::SchemaMismatch
    Number(100, ..) => ErrorCode::DataCoordNA
    Number(1000, ..) => ErrorCode::DDRequestRace
    Number(value, ..) =>
      if value.trunc() == value {
        ErrorCode::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for ErrorCode with fn to_json(self : ErrorCode) -> Json {
  match self {
    ErrorCode::Success => "Success"
    ErrorCode::UnexpectedError => "UnexpectedError"
    ErrorCode::ConnectFailed => "ConnectFailed"
    ErrorCode::PermissionDenied => "PermissionDenied"
    ErrorCode::CollectionNotExists => "CollectionNotExists"
    ErrorCode::IllegalArgument => "IllegalArgument"
    ErrorCode::IllegalDimension => "IllegalDimension"
    ErrorCode::IllegalIndexType => "IllegalIndexType"
    ErrorCode::IllegalCollectionName => "IllegalCollectionName"
    ErrorCode::IllegalTOPK => "IllegalTOPK"
    ErrorCode::IllegalRowRecord => "IllegalRowRecord"
    ErrorCode::IllegalVectorID => "IllegalVectorID"
    ErrorCode::IllegalSearchResult => "IllegalSearchResult"
    ErrorCode::FileNotFound => "FileNotFound"
    ErrorCode::MetaFailed => "MetaFailed"
    ErrorCode::CacheFailed => "CacheFailed"
    ErrorCode::CannotCreateFolder => "CannotCreateFolder"
    ErrorCode::CannotCreateFile => "CannotCreateFile"
    ErrorCode::CannotDeleteFolder => "CannotDeleteFolder"
    ErrorCode::CannotDeleteFile => "CannotDeleteFile"
    ErrorCode::BuildIndexError => "BuildIndexError"
    ErrorCode::IllegalNLIST => "IllegalNLIST"
    ErrorCode::IllegalMetricType => "IllegalMetricType"
    ErrorCode::OutOfMemory => "OutOfMemory"
    ErrorCode::IndexNotExist => "IndexNotExist"
    ErrorCode::EmptyCollection => "EmptyCollection"
    ErrorCode::UpdateImportTaskFailure => "UpdateImportTaskFailure"
    ErrorCode::CollectionNameNotFound => "CollectionNameNotFound"
    ErrorCode::CreateCredentialFailure => "CreateCredentialFailure"
    ErrorCode::UpdateCredentialFailure => "UpdateCredentialFailure"
    ErrorCode::DeleteCredentialFailure => "DeleteCredentialFailure"
    ErrorCode::GetCredentialFailure => "GetCredentialFailure"
    ErrorCode::ListCredUsersFailure => "ListCredUsersFailure"
    ErrorCode::GetUserFailure => "GetUserFailure"
    ErrorCode::CreateRoleFailure => "CreateRoleFailure"
    ErrorCode::DropRoleFailure => "DropRoleFailure"
    ErrorCode::OperateUserRoleFailure => "OperateUserRoleFailure"
    ErrorCode::SelectRoleFailure => "SelectRoleFailure"
    ErrorCode::SelectUserFailure => "SelectUserFailure"
    ErrorCode::SelectResourceFailure => "SelectResourceFailure"
    ErrorCode::OperatePrivilegeFailure => "OperatePrivilegeFailure"
    ErrorCode::SelectGrantFailure => "SelectGrantFailure"
    ErrorCode::RefreshPolicyInfoCacheFailure => "RefreshPolicyInfoCacheFailure"
    ErrorCode::ListPolicyFailure => "ListPolicyFailure"
    ErrorCode::NotShardLeader => "NotShardLeader"
    ErrorCode::NoReplicaAvailable => "NoReplicaAvailable"
    ErrorCode::SegmentNotFound => "SegmentNotFound"
    ErrorCode::ForceDeny => "ForceDeny"
    ErrorCode::RateLimit => "RateLimit"
    ErrorCode::NodeIDNotMatch => "NodeIDNotMatch"
    ErrorCode::UpsertAutoIDTrue => "UpsertAutoIDTrue"
    ErrorCode::InsufficientMemoryToLoad => "InsufficientMemoryToLoad"
    ErrorCode::MemoryQuotaExhausted => "MemoryQuotaExhausted"
    ErrorCode::DiskQuotaExhausted => "DiskQuotaExhausted"
    ErrorCode::TimeTickLongDelay => "TimeTickLongDelay"
    ErrorCode::NotReadyServe => "NotReadyServe"
    ErrorCode::NotReadyCoordActivating => "NotReadyCoordActivating"
    ErrorCode::CreatePrivilegeGroupFailure => "CreatePrivilegeGroupFailure"
    ErrorCode::DropPrivilegeGroupFailure => "DropPrivilegeGroupFailure"
    ErrorCode::ListPrivilegeGroupsFailure => "ListPrivilegeGroupsFailure"
    ErrorCode::OperatePrivilegeGroupFailure => "OperatePrivilegeGroupFailure"
    ErrorCode::SchemaMismatch => "SchemaMismatch"
    ErrorCode::DataCoordNA => "DataCoordNA"
    ErrorCode::DDRequestRace => "DDRequestRace"
    ErrorCode::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) enum MsgType {
  Undefined
  CreateCollection
  DropCollection
  HasCollection
  DescribeCollection
  ShowCollections
  GetSystemConfigs
  LoadCollection
  ReleaseCollection
  CreateAlias
  DropAlias
  AlterAlias
  AlterCollection
  RenameCollection
  DescribeAlias
  ListAliases
  AlterCollectionField
  AddCollectionFunction
  AlterCollectionFunction
  DropCollectionFunction
  TruncateCollection
  SplitShard
  CreatePartition
  DropPartition
  HasPartition
  DescribePartition
  ShowPartitions
  LoadPartitions
  ReleasePartitions
  ShowSegments
  DescribeSegment
  LoadSegments
  ReleaseSegments
  HandoffSegments
  LoadBalanceSegments
  DescribeSegments
  FederListIndexedSegment
  FederDescribeSegmentIndexData
  CreateIndex
  DescribeIndex
  DropIndex
  GetIndexStatistics
  AlterIndex
  Insert
  Delete
  Flush
  ResendSegmentStats
  Upsert
  ManualFlush
  FlushSegment
  CreateSegment
  Import
  FlushAll
  Search
  SearchResult
  GetIndexState
  GetIndexBuildProgress
  GetCollectionStatistics
  GetPartitionStatistics
  Retrieve
  RetrieveResult
  WatchDmChannels
  RemoveDmChannels
  WatchQueryChannels
  RemoveQueryChannels
  SealedSegmentsChangeInfo
  WatchDeltaChannels
  GetShardLeaders
  GetReplicas
  UnsubDmChannel
  GetDistribution
  SyncDistribution
  RunAnalyzer
  SegmentInfo
  SystemInfo
  GetRecoveryInfo
  GetSegmentState
  TimeTick
  QueryNodeStats
  LoadIndex
  RequestID
  RequestTSO
  AllocateSegment
  SegmentStatistics
  SegmentFlushDone
  DataNodeTt
  Connect
  ListClientInfos
  AllocTimestamp
  Replicate
  CreateCredential
  GetCredential
  DeleteCredential
  UpdateCredential
  ListCredUsernames
  CreateRole
  DropRole
  OperateUserRole
  SelectRole
  SelectUser
  SelectResource
  OperatePrivilege
  SelectGrant
  RefreshPolicyInfoCache
  ListPolicy
  CreatePrivilegeGroup
  DropPrivilegeGroup
  ListPrivilegeGroups
  OperatePrivilegeGroup
  OperatePrivilegeV2
  AlterRole
  CreateResourceGroup
  DropResourceGroup
  ListResourceGroups
  DescribeResourceGroup
  TransferNode
  TransferReplica
  UpdateResourceGroups
  CreateDatabase
  DropDatabase
  ListDatabases
  AlterDatabase
  DescribeDatabase
  AddCollectionField
  AlterWAL
  CreateSnapshot
  DropSnapshot
  ListSnapshots
  DescribeSnapshot
  RestoreSnapshot
  GetRestoreSnapshotState
  ListRestoreSnapshotJobs
  PinSnapshotData
  UnpinSnapshotData
  RestoreExternalSnapshot
  ExportSnapshot
  AlterCollectionSchema
  RefreshExternalCollection
  GetRefreshExternalCollectionProgress
  ListRefreshExternalCollectionJobs
  CreateRowPolicy
  DropRowPolicy
  ListRowPolicies
  UpdateRowPolicy
  SetRLSPrincipalTags
  GetRLSPrincipalTags
  ListRLSPrincipals
  DeleteRLSPrincipalTags
  GetExportSnapshotState
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn MsgType::to_enum(self : MsgType) -> @lib.Enum {
  match self {
    MsgType::Undefined => 0
    MsgType::CreateCollection => 100
    MsgType::DropCollection => 101
    MsgType::HasCollection => 102
    MsgType::DescribeCollection => 103
    MsgType::ShowCollections => 104
    MsgType::GetSystemConfigs => 105
    MsgType::LoadCollection => 106
    MsgType::ReleaseCollection => 107
    MsgType::CreateAlias => 108
    MsgType::DropAlias => 109
    MsgType::AlterAlias => 110
    MsgType::AlterCollection => 111
    MsgType::RenameCollection => 112
    MsgType::DescribeAlias => 113
    MsgType::ListAliases => 114
    MsgType::AlterCollectionField => 115
    MsgType::AddCollectionFunction => 116
    MsgType::AlterCollectionFunction => 117
    MsgType::DropCollectionFunction => 118
    MsgType::TruncateCollection => 119
    MsgType::SplitShard => 120
    MsgType::CreatePartition => 200
    MsgType::DropPartition => 201
    MsgType::HasPartition => 202
    MsgType::DescribePartition => 203
    MsgType::ShowPartitions => 204
    MsgType::LoadPartitions => 205
    MsgType::ReleasePartitions => 206
    MsgType::ShowSegments => 250
    MsgType::DescribeSegment => 251
    MsgType::LoadSegments => 252
    MsgType::ReleaseSegments => 253
    MsgType::HandoffSegments => 254
    MsgType::LoadBalanceSegments => 255
    MsgType::DescribeSegments => 256
    MsgType::FederListIndexedSegment => 257
    MsgType::FederDescribeSegmentIndexData => 258
    MsgType::CreateIndex => 300
    MsgType::DescribeIndex => 301
    MsgType::DropIndex => 302
    MsgType::GetIndexStatistics => 303
    MsgType::AlterIndex => 304
    MsgType::Insert => 400
    MsgType::Delete => 401
    MsgType::Flush => 402
    MsgType::ResendSegmentStats => 403
    MsgType::Upsert => 404
    MsgType::ManualFlush => 405
    MsgType::FlushSegment => 406
    MsgType::CreateSegment => 407
    MsgType::Import => 408
    MsgType::FlushAll => 409
    MsgType::Search => 500
    MsgType::SearchResult => 501
    MsgType::GetIndexState => 502
    MsgType::GetIndexBuildProgress => 503
    MsgType::GetCollectionStatistics => 504
    MsgType::GetPartitionStatistics => 505
    MsgType::Retrieve => 506
    MsgType::RetrieveResult => 507
    MsgType::WatchDmChannels => 508
    MsgType::RemoveDmChannels => 509
    MsgType::WatchQueryChannels => 510
    MsgType::RemoveQueryChannels => 511
    MsgType::SealedSegmentsChangeInfo => 512
    MsgType::WatchDeltaChannels => 513
    MsgType::GetShardLeaders => 514
    MsgType::GetReplicas => 515
    MsgType::UnsubDmChannel => 516
    MsgType::GetDistribution => 517
    MsgType::SyncDistribution => 518
    MsgType::RunAnalyzer => 519
    MsgType::SegmentInfo => 600
    MsgType::SystemInfo => 601
    MsgType::GetRecoveryInfo => 602
    MsgType::GetSegmentState => 603
    MsgType::TimeTick => 1200
    MsgType::QueryNodeStats => 1201
    MsgType::LoadIndex => 1202
    MsgType::RequestID => 1203
    MsgType::RequestTSO => 1204
    MsgType::AllocateSegment => 1205
    MsgType::SegmentStatistics => 1206
    MsgType::SegmentFlushDone => 1207
    MsgType::DataNodeTt => 1208
    MsgType::Connect => 1209
    MsgType::ListClientInfos => 1210
    MsgType::AllocTimestamp => 1211
    MsgType::Replicate => 1212
    MsgType::CreateCredential => 1500
    MsgType::GetCredential => 1501
    MsgType::DeleteCredential => 1502
    MsgType::UpdateCredential => 1503
    MsgType::ListCredUsernames => 1504
    MsgType::CreateRole => 1600
    MsgType::DropRole => 1601
    MsgType::OperateUserRole => 1602
    MsgType::SelectRole => 1603
    MsgType::SelectUser => 1604
    MsgType::SelectResource => 1605
    MsgType::OperatePrivilege => 1606
    MsgType::SelectGrant => 1607
    MsgType::RefreshPolicyInfoCache => 1608
    MsgType::ListPolicy => 1609
    MsgType::CreatePrivilegeGroup => 1610
    MsgType::DropPrivilegeGroup => 1611
    MsgType::ListPrivilegeGroups => 1612
    MsgType::OperatePrivilegeGroup => 1613
    MsgType::OperatePrivilegeV2 => 1614
    MsgType::AlterRole => 1615
    MsgType::CreateResourceGroup => 1700
    MsgType::DropResourceGroup => 1701
    MsgType::ListResourceGroups => 1702
    MsgType::DescribeResourceGroup => 1703
    MsgType::TransferNode => 1704
    MsgType::TransferReplica => 1705
    MsgType::UpdateResourceGroups => 1706
    MsgType::CreateDatabase => 1801
    MsgType::DropDatabase => 1802
    MsgType::ListDatabases => 1803
    MsgType::AlterDatabase => 1804
    MsgType::DescribeDatabase => 1805
    MsgType::AddCollectionField => 1900
    MsgType::AlterWAL => 2000
    MsgType::CreateSnapshot => 2100
    MsgType::DropSnapshot => 2101
    MsgType::ListSnapshots => 2102
    MsgType::DescribeSnapshot => 2103
    MsgType::RestoreSnapshot => 2104
    MsgType::GetRestoreSnapshotState => 2105
    MsgType::ListRestoreSnapshotJobs => 2106
    MsgType::PinSnapshotData => 2107
    MsgType::UnpinSnapshotData => 2108
    MsgType::RestoreExternalSnapshot => 2109
    MsgType::ExportSnapshot => 2110
    MsgType::AlterCollectionSchema => 2200
    MsgType::RefreshExternalCollection => 2300
    MsgType::GetRefreshExternalCollectionProgress => 2301
    MsgType::ListRefreshExternalCollectionJobs => 2302
    MsgType::CreateRowPolicy => 2400
    MsgType::DropRowPolicy => 2401
    MsgType::ListRowPolicies => 2402
    MsgType::UpdateRowPolicy => 2403
    MsgType::SetRLSPrincipalTags => 2404
    MsgType::GetRLSPrincipalTags => 2405
    MsgType::ListRLSPrincipals => 2406
    MsgType::DeleteRLSPrincipalTags => 2407
    MsgType::GetExportSnapshotState => 2111
    MsgType::Unknown(value) => value
  }
}

///|
pub fn MsgType::from_enum(i : @lib.Enum) -> MsgType {
  match i.0 {
    0 => MsgType::Undefined
    100 => MsgType::CreateCollection
    101 => MsgType::DropCollection
    102 => MsgType::HasCollection
    103 => MsgType::DescribeCollection
    104 => MsgType::ShowCollections
    105 => MsgType::GetSystemConfigs
    106 => MsgType::LoadCollection
    107 => MsgType::ReleaseCollection
    108 => MsgType::CreateAlias
    109 => MsgType::DropAlias
    110 => MsgType::AlterAlias
    111 => MsgType::AlterCollection
    112 => MsgType::RenameCollection
    113 => MsgType::DescribeAlias
    114 => MsgType::ListAliases
    115 => MsgType::AlterCollectionField
    116 => MsgType::AddCollectionFunction
    117 => MsgType::AlterCollectionFunction
    118 => MsgType::DropCollectionFunction
    119 => MsgType::TruncateCollection
    120 => MsgType::SplitShard
    200 => MsgType::CreatePartition
    201 => MsgType::DropPartition
    202 => MsgType::HasPartition
    203 => MsgType::DescribePartition
    204 => MsgType::ShowPartitions
    205 => MsgType::LoadPartitions
    206 => MsgType::ReleasePartitions
    250 => MsgType::ShowSegments
    251 => MsgType::DescribeSegment
    252 => MsgType::LoadSegments
    253 => MsgType::ReleaseSegments
    254 => MsgType::HandoffSegments
    255 => MsgType::LoadBalanceSegments
    256 => MsgType::DescribeSegments
    257 => MsgType::FederListIndexedSegment
    258 => MsgType::FederDescribeSegmentIndexData
    300 => MsgType::CreateIndex
    301 => MsgType::DescribeIndex
    302 => MsgType::DropIndex
    303 => MsgType::GetIndexStatistics
    304 => MsgType::AlterIndex
    400 => MsgType::Insert
    401 => MsgType::Delete
    402 => MsgType::Flush
    403 => MsgType::ResendSegmentStats
    404 => MsgType::Upsert
    405 => MsgType::ManualFlush
    406 => MsgType::FlushSegment
    407 => MsgType::CreateSegment
    408 => MsgType::Import
    409 => MsgType::FlushAll
    500 => MsgType::Search
    501 => MsgType::SearchResult
    502 => MsgType::GetIndexState
    503 => MsgType::GetIndexBuildProgress
    504 => MsgType::GetCollectionStatistics
    505 => MsgType::GetPartitionStatistics
    506 => MsgType::Retrieve
    507 => MsgType::RetrieveResult
    508 => MsgType::WatchDmChannels
    509 => MsgType::RemoveDmChannels
    510 => MsgType::WatchQueryChannels
    511 => MsgType::RemoveQueryChannels
    512 => MsgType::SealedSegmentsChangeInfo
    513 => MsgType::WatchDeltaChannels
    514 => MsgType::GetShardLeaders
    515 => MsgType::GetReplicas
    516 => MsgType::UnsubDmChannel
    517 => MsgType::GetDistribution
    518 => MsgType::SyncDistribution
    519 => MsgType::RunAnalyzer
    600 => MsgType::SegmentInfo
    601 => MsgType::SystemInfo
    602 => MsgType::GetRecoveryInfo
    603 => MsgType::GetSegmentState
    1200 => MsgType::TimeTick
    1201 => MsgType::QueryNodeStats
    1202 => MsgType::LoadIndex
    1203 => MsgType::RequestID
    1204 => MsgType::RequestTSO
    1205 => MsgType::AllocateSegment
    1206 => MsgType::SegmentStatistics
    1207 => MsgType::SegmentFlushDone
    1208 => MsgType::DataNodeTt
    1209 => MsgType::Connect
    1210 => MsgType::ListClientInfos
    1211 => MsgType::AllocTimestamp
    1212 => MsgType::Replicate
    1500 => MsgType::CreateCredential
    1501 => MsgType::GetCredential
    1502 => MsgType::DeleteCredential
    1503 => MsgType::UpdateCredential
    1504 => MsgType::ListCredUsernames
    1600 => MsgType::CreateRole
    1601 => MsgType::DropRole
    1602 => MsgType::OperateUserRole
    1603 => MsgType::SelectRole
    1604 => MsgType::SelectUser
    1605 => MsgType::SelectResource
    1606 => MsgType::OperatePrivilege
    1607 => MsgType::SelectGrant
    1608 => MsgType::RefreshPolicyInfoCache
    1609 => MsgType::ListPolicy
    1610 => MsgType::CreatePrivilegeGroup
    1611 => MsgType::DropPrivilegeGroup
    1612 => MsgType::ListPrivilegeGroups
    1613 => MsgType::OperatePrivilegeGroup
    1614 => MsgType::OperatePrivilegeV2
    1615 => MsgType::AlterRole
    1700 => MsgType::CreateResourceGroup
    1701 => MsgType::DropResourceGroup
    1702 => MsgType::ListResourceGroups
    1703 => MsgType::DescribeResourceGroup
    1704 => MsgType::TransferNode
    1705 => MsgType::TransferReplica
    1706 => MsgType::UpdateResourceGroups
    1801 => MsgType::CreateDatabase
    1802 => MsgType::DropDatabase
    1803 => MsgType::ListDatabases
    1804 => MsgType::AlterDatabase
    1805 => MsgType::DescribeDatabase
    1900 => MsgType::AddCollectionField
    2000 => MsgType::AlterWAL
    2100 => MsgType::CreateSnapshot
    2101 => MsgType::DropSnapshot
    2102 => MsgType::ListSnapshots
    2103 => MsgType::DescribeSnapshot
    2104 => MsgType::RestoreSnapshot
    2105 => MsgType::GetRestoreSnapshotState
    2106 => MsgType::ListRestoreSnapshotJobs
    2107 => MsgType::PinSnapshotData
    2108 => MsgType::UnpinSnapshotData
    2109 => MsgType::RestoreExternalSnapshot
    2110 => MsgType::ExportSnapshot
    2200 => MsgType::AlterCollectionSchema
    2300 => MsgType::RefreshExternalCollection
    2301 => MsgType::GetRefreshExternalCollectionProgress
    2302 => MsgType::ListRefreshExternalCollectionJobs
    2400 => MsgType::CreateRowPolicy
    2401 => MsgType::DropRowPolicy
    2402 => MsgType::ListRowPolicies
    2403 => MsgType::UpdateRowPolicy
    2404 => MsgType::SetRLSPrincipalTags
    2405 => MsgType::GetRLSPrincipalTags
    2406 => MsgType::ListRLSPrincipals
    2407 => MsgType::DeleteRLSPrincipalTags
    2111 => MsgType::GetExportSnapshotState
    _ => MsgType::Unknown(i)
  }
}

///|
pub impl Default for MsgType with fn default() -> MsgType {
  MsgType::Undefined
}

///|
pub impl @lib.Sized for MsgType with fn size_of(self : MsgType) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for MsgType with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> MsgType raise {
  match json {
    String("Undefined") => MsgType::Undefined
    String("CreateCollection") => MsgType::CreateCollection
    String("DropCollection") => MsgType::DropCollection
    String("HasCollection") => MsgType::HasCollection
    String("DescribeCollection") => MsgType::DescribeCollection
    String("ShowCollections") => MsgType::ShowCollections
    String("GetSystemConfigs") => MsgType::GetSystemConfigs
    String("LoadCollection") => MsgType::LoadCollection
    String("ReleaseCollection") => MsgType::ReleaseCollection
    String("CreateAlias") => MsgType::CreateAlias
    String("DropAlias") => MsgType::DropAlias
    String("AlterAlias") => MsgType::AlterAlias
    String("AlterCollection") => MsgType::AlterCollection
    String("RenameCollection") => MsgType::RenameCollection
    String("DescribeAlias") => MsgType::DescribeAlias
    String("ListAliases") => MsgType::ListAliases
    String("AlterCollectionField") => MsgType::AlterCollectionField
    String("AddCollectionFunction") => MsgType::AddCollectionFunction
    String("AlterCollectionFunction") => MsgType::AlterCollectionFunction
    String("DropCollectionFunction") => MsgType::DropCollectionFunction
    String("TruncateCollection") => MsgType::TruncateCollection
    String("SplitShard") => MsgType::SplitShard
    String("CreatePartition") => MsgType::CreatePartition
    String("DropPartition") => MsgType::DropPartition
    String("HasPartition") => MsgType::HasPartition
    String("DescribePartition") => MsgType::DescribePartition
    String("ShowPartitions") => MsgType::ShowPartitions
    String("LoadPartitions") => MsgType::LoadPartitions
    String("ReleasePartitions") => MsgType::ReleasePartitions
    String("ShowSegments") => MsgType::ShowSegments
    String("DescribeSegment") => MsgType::DescribeSegment
    String("LoadSegments") => MsgType::LoadSegments
    String("ReleaseSegments") => MsgType::ReleaseSegments
    String("HandoffSegments") => MsgType::HandoffSegments
    String("LoadBalanceSegments") => MsgType::LoadBalanceSegments
    String("DescribeSegments") => MsgType::DescribeSegments
    String("FederListIndexedSegment") => MsgType::FederListIndexedSegment
    String("FederDescribeSegmentIndexData") =>
      MsgType::FederDescribeSegmentIndexData
    String("CreateIndex") => MsgType::CreateIndex
    String("DescribeIndex") => MsgType::DescribeIndex
    String("DropIndex") => MsgType::DropIndex
    String("GetIndexStatistics") => MsgType::GetIndexStatistics
    String("AlterIndex") => MsgType::AlterIndex
    String("Insert") => MsgType::Insert
    String("Delete") => MsgType::Delete
    String("Flush") => MsgType::Flush
    String("ResendSegmentStats") => MsgType::ResendSegmentStats
    String("Upsert") => MsgType::Upsert
    String("ManualFlush") => MsgType::ManualFlush
    String("FlushSegment") => MsgType::FlushSegment
    String("CreateSegment") => MsgType::CreateSegment
    String("Import") => MsgType::Import
    String("FlushAll") => MsgType::FlushAll
    String("Search") => MsgType::Search
    String("SearchResult") => MsgType::SearchResult
    String("GetIndexState") => MsgType::GetIndexState
    String("GetIndexBuildProgress") => MsgType::GetIndexBuildProgress
    String("GetCollectionStatistics") => MsgType::GetCollectionStatistics
    String("GetPartitionStatistics") => MsgType::GetPartitionStatistics
    String("Retrieve") => MsgType::Retrieve
    String("RetrieveResult") => MsgType::RetrieveResult
    String("WatchDmChannels") => MsgType::WatchDmChannels
    String("RemoveDmChannels") => MsgType::RemoveDmChannels
    String("WatchQueryChannels") => MsgType::WatchQueryChannels
    String("RemoveQueryChannels") => MsgType::RemoveQueryChannels
    String("SealedSegmentsChangeInfo") => MsgType::SealedSegmentsChangeInfo
    String("WatchDeltaChannels") => MsgType::WatchDeltaChannels
    String("GetShardLeaders") => MsgType::GetShardLeaders
    String("GetReplicas") => MsgType::GetReplicas
    String("UnsubDmChannel") => MsgType::UnsubDmChannel
    String("GetDistribution") => MsgType::GetDistribution
    String("SyncDistribution") => MsgType::SyncDistribution
    String("RunAnalyzer") => MsgType::RunAnalyzer
    String("SegmentInfo") => MsgType::SegmentInfo
    String("SystemInfo") => MsgType::SystemInfo
    String("GetRecoveryInfo") => MsgType::GetRecoveryInfo
    String("GetSegmentState") => MsgType::GetSegmentState
    String("TimeTick") => MsgType::TimeTick
    String("QueryNodeStats") => MsgType::QueryNodeStats
    String("LoadIndex") => MsgType::LoadIndex
    String("RequestID") => MsgType::RequestID
    String("RequestTSO") => MsgType::RequestTSO
    String("AllocateSegment") => MsgType::AllocateSegment
    String("SegmentStatistics") => MsgType::SegmentStatistics
    String("SegmentFlushDone") => MsgType::SegmentFlushDone
    String("DataNodeTt") => MsgType::DataNodeTt
    String("Connect") => MsgType::Connect
    String("ListClientInfos") => MsgType::ListClientInfos
    String("AllocTimestamp") => MsgType::AllocTimestamp
    String("Replicate") => MsgType::Replicate
    String("CreateCredential") => MsgType::CreateCredential
    String("GetCredential") => MsgType::GetCredential
    String("DeleteCredential") => MsgType::DeleteCredential
    String("UpdateCredential") => MsgType::UpdateCredential
    String("ListCredUsernames") => MsgType::ListCredUsernames
    String("CreateRole") => MsgType::CreateRole
    String("DropRole") => MsgType::DropRole
    String("OperateUserRole") => MsgType::OperateUserRole
    String("SelectRole") => MsgType::SelectRole
    String("SelectUser") => MsgType::SelectUser
    String("SelectResource") => MsgType::SelectResource
    String("OperatePrivilege") => MsgType::OperatePrivilege
    String("SelectGrant") => MsgType::SelectGrant
    String("RefreshPolicyInfoCache") => MsgType::RefreshPolicyInfoCache
    String("ListPolicy") => MsgType::ListPolicy
    String("CreatePrivilegeGroup") => MsgType::CreatePrivilegeGroup
    String("DropPrivilegeGroup") => MsgType::DropPrivilegeGroup
    String("ListPrivilegeGroups") => MsgType::ListPrivilegeGroups
    String("OperatePrivilegeGroup") => MsgType::OperatePrivilegeGroup
    String("OperatePrivilegeV2") => MsgType::OperatePrivilegeV2
    String("AlterRole") => MsgType::AlterRole
    String("CreateResourceGroup") => MsgType::CreateResourceGroup
    String("DropResourceGroup") => MsgType::DropResourceGroup
    String("ListResourceGroups") => MsgType::ListResourceGroups
    String("DescribeResourceGroup") => MsgType::DescribeResourceGroup
    String("TransferNode") => MsgType::TransferNode
    String("TransferReplica") => MsgType::TransferReplica
    String("UpdateResourceGroups") => MsgType::UpdateResourceGroups
    String("CreateDatabase") => MsgType::CreateDatabase
    String("DropDatabase") => MsgType::DropDatabase
    String("ListDatabases") => MsgType::ListDatabases
    String("AlterDatabase") => MsgType::AlterDatabase
    String("DescribeDatabase") => MsgType::DescribeDatabase
    String("AddCollectionField") => MsgType::AddCollectionField
    String("AlterWAL") => MsgType::AlterWAL
    String("CreateSnapshot") => MsgType::CreateSnapshot
    String("DropSnapshot") => MsgType::DropSnapshot
    String("ListSnapshots") => MsgType::ListSnapshots
    String("DescribeSnapshot") => MsgType::DescribeSnapshot
    String("RestoreSnapshot") => MsgType::RestoreSnapshot
    String("GetRestoreSnapshotState") => MsgType::GetRestoreSnapshotState
    String("ListRestoreSnapshotJobs") => MsgType::ListRestoreSnapshotJobs
    String("PinSnapshotData") => MsgType::PinSnapshotData
    String("UnpinSnapshotData") => MsgType::UnpinSnapshotData
    String("RestoreExternalSnapshot") => MsgType::RestoreExternalSnapshot
    String("ExportSnapshot") => MsgType::ExportSnapshot
    String("AlterCollectionSchema") => MsgType::AlterCollectionSchema
    String("RefreshExternalCollection") => MsgType::RefreshExternalCollection
    String("GetRefreshExternalCollectionProgress") =>
      MsgType::GetRefreshExternalCollectionProgress
    String("ListRefreshExternalCollectionJobs") =>
      MsgType::ListRefreshExternalCollectionJobs
    String("CreateRowPolicy") => MsgType::CreateRowPolicy
    String("DropRowPolicy") => MsgType::DropRowPolicy
    String("ListRowPolicies") => MsgType::ListRowPolicies
    String("UpdateRowPolicy") => MsgType::UpdateRowPolicy
    String("SetRLSPrincipalTags") => MsgType::SetRLSPrincipalTags
    String("GetRLSPrincipalTags") => MsgType::GetRLSPrincipalTags
    String("ListRLSPrincipals") => MsgType::ListRLSPrincipals
    String("DeleteRLSPrincipalTags") => MsgType::DeleteRLSPrincipalTags
    String("GetExportSnapshotState") => MsgType::GetExportSnapshotState
    Number(0, ..) => MsgType::Undefined
    Number(100, ..) => MsgType::CreateCollection
    Number(101, ..) => MsgType::DropCollection
    Number(102, ..) => MsgType::HasCollection
    Number(103, ..) => MsgType::DescribeCollection
    Number(104, ..) => MsgType::ShowCollections
    Number(105, ..) => MsgType::GetSystemConfigs
    Number(106, ..) => MsgType::LoadCollection
    Number(107, ..) => MsgType::ReleaseCollection
    Number(108, ..) => MsgType::CreateAlias
    Number(109, ..) => MsgType::DropAlias
    Number(110, ..) => MsgType::AlterAlias
    Number(111, ..) => MsgType::AlterCollection
    Number(112, ..) => MsgType::RenameCollection
    Number(113, ..) => MsgType::DescribeAlias
    Number(114, ..) => MsgType::ListAliases
    Number(115, ..) => MsgType::AlterCollectionField
    Number(116, ..) => MsgType::AddCollectionFunction
    Number(117, ..) => MsgType::AlterCollectionFunction
    Number(118, ..) => MsgType::DropCollectionFunction
    Number(119, ..) => MsgType::TruncateCollection
    Number(120, ..) => MsgType::SplitShard
    Number(200, ..) => MsgType::CreatePartition
    Number(201, ..) => MsgType::DropPartition
    Number(202, ..) => MsgType::HasPartition
    Number(203, ..) => MsgType::DescribePartition
    Number(204, ..) => MsgType::ShowPartitions
    Number(205, ..) => MsgType::LoadPartitions
    Number(206, ..) => MsgType::ReleasePartitions
    Number(250, ..) => MsgType::ShowSegments
    Number(251, ..) => MsgType::DescribeSegment
    Number(252, ..) => MsgType::LoadSegments
    Number(253, ..) => MsgType::ReleaseSegments
    Number(254, ..) => MsgType::HandoffSegments
    Number(255, ..) => MsgType::LoadBalanceSegments
    Number(256, ..) => MsgType::DescribeSegments
    Number(257, ..) => MsgType::FederListIndexedSegment
    Number(258, ..) => MsgType::FederDescribeSegmentIndexData
    Number(300, ..) => MsgType::CreateIndex
    Number(301, ..) => MsgType::DescribeIndex
    Number(302, ..) => MsgType::DropIndex
    Number(303, ..) => MsgType::GetIndexStatistics
    Number(304, ..) => MsgType::AlterIndex
    Number(400, ..) => MsgType::Insert
    Number(401, ..) => MsgType::Delete
    Number(402, ..) => MsgType::Flush
    Number(403, ..) => MsgType::ResendSegmentStats
    Number(404, ..) => MsgType::Upsert
    Number(405, ..) => MsgType::ManualFlush
    Number(406, ..) => MsgType::FlushSegment
    Number(407, ..) => MsgType::CreateSegment
    Number(408, ..) => MsgType::Import
    Number(409, ..) => MsgType::FlushAll
    Number(500, ..) => MsgType::Search
    Number(501, ..) => MsgType::SearchResult
    Number(502, ..) => MsgType::GetIndexState
    Number(503, ..) => MsgType::GetIndexBuildProgress
    Number(504, ..) => MsgType::GetCollectionStatistics
    Number(505, ..) => MsgType::GetPartitionStatistics
    Number(506, ..) => MsgType::Retrieve
    Number(507, ..) => MsgType::RetrieveResult
    Number(508, ..) => MsgType::WatchDmChannels
    Number(509, ..) => MsgType::RemoveDmChannels
    Number(510, ..) => MsgType::WatchQueryChannels
    Number(511, ..) => MsgType::RemoveQueryChannels
    Number(512, ..) => MsgType::SealedSegmentsChangeInfo
    Number(513, ..) => MsgType::WatchDeltaChannels
    Number(514, ..) => MsgType::GetShardLeaders
    Number(515, ..) => MsgType::GetReplicas
    Number(516, ..) => MsgType::UnsubDmChannel
    Number(517, ..) => MsgType::GetDistribution
    Number(518, ..) => MsgType::SyncDistribution
    Number(519, ..) => MsgType::RunAnalyzer
    Number(600, ..) => MsgType::SegmentInfo
    Number(601, ..) => MsgType::SystemInfo
    Number(602, ..) => MsgType::GetRecoveryInfo
    Number(603, ..) => MsgType::GetSegmentState
    Number(1200, ..) => MsgType::TimeTick
    Number(1201, ..) => MsgType::QueryNodeStats
    Number(1202, ..) => MsgType::LoadIndex
    Number(1203, ..) => MsgType::RequestID
    Number(1204, ..) => MsgType::RequestTSO
    Number(1205, ..) => MsgType::AllocateSegment
    Number(1206, ..) => MsgType::SegmentStatistics
    Number(1207, ..) => MsgType::SegmentFlushDone
    Number(1208, ..) => MsgType::DataNodeTt
    Number(1209, ..) => MsgType::Connect
    Number(1210, ..) => MsgType::ListClientInfos
    Number(1211, ..) => MsgType::AllocTimestamp
    Number(1212, ..) => MsgType::Replicate
    Number(1500, ..) => MsgType::CreateCredential
    Number(1501, ..) => MsgType::GetCredential
    Number(1502, ..) => MsgType::DeleteCredential
    Number(1503, ..) => MsgType::UpdateCredential
    Number(1504, ..) => MsgType::ListCredUsernames
    Number(1600, ..) => MsgType::CreateRole
    Number(1601, ..) => MsgType::DropRole
    Number(1602, ..) => MsgType::OperateUserRole
    Number(1603, ..) => MsgType::SelectRole
    Number(1604, ..) => MsgType::SelectUser
    Number(1605, ..) => MsgType::SelectResource
    Number(1606, ..) => MsgType::OperatePrivilege
    Number(1607, ..) => MsgType::SelectGrant
    Number(1608, ..) => MsgType::RefreshPolicyInfoCache
    Number(1609, ..) => MsgType::ListPolicy
    Number(1610, ..) => MsgType::CreatePrivilegeGroup
    Number(1611, ..) => MsgType::DropPrivilegeGroup
    Number(1612, ..) => MsgType::ListPrivilegeGroups
    Number(1613, ..) => MsgType::OperatePrivilegeGroup
    Number(1614, ..) => MsgType::OperatePrivilegeV2
    Number(1615, ..) => MsgType::AlterRole
    Number(1700, ..) => MsgType::CreateResourceGroup
    Number(1701, ..) => MsgType::DropResourceGroup
    Number(1702, ..) => MsgType::ListResourceGroups
    Number(1703, ..) => MsgType::DescribeResourceGroup
    Number(1704, ..) => MsgType::TransferNode
    Number(1705, ..) => MsgType::TransferReplica
    Number(1706, ..) => MsgType::UpdateResourceGroups
    Number(1801, ..) => MsgType::CreateDatabase
    Number(1802, ..) => MsgType::DropDatabase
    Number(1803, ..) => MsgType::ListDatabases
    Number(1804, ..) => MsgType::AlterDatabase
    Number(1805, ..) => MsgType::DescribeDatabase
    Number(1900, ..) => MsgType::AddCollectionField
    Number(2000, ..) => MsgType::AlterWAL
    Number(2100, ..) => MsgType::CreateSnapshot
    Number(2101, ..) => MsgType::DropSnapshot
    Number(2102, ..) => MsgType::ListSnapshots
    Number(2103, ..) => MsgType::DescribeSnapshot
    Number(2104, ..) => MsgType::RestoreSnapshot
    Number(2105, ..) => MsgType::GetRestoreSnapshotState
    Number(2106, ..) => MsgType::ListRestoreSnapshotJobs
    Number(2107, ..) => MsgType::PinSnapshotData
    Number(2108, ..) => MsgType::UnpinSnapshotData
    Number(2109, ..) => MsgType::RestoreExternalSnapshot
    Number(2110, ..) => MsgType::ExportSnapshot
    Number(2200, ..) => MsgType::AlterCollectionSchema
    Number(2300, ..) => MsgType::RefreshExternalCollection
    Number(2301, ..) => MsgType::GetRefreshExternalCollectionProgress
    Number(2302, ..) => MsgType::ListRefreshExternalCollectionJobs
    Number(2400, ..) => MsgType::CreateRowPolicy
    Number(2401, ..) => MsgType::DropRowPolicy
    Number(2402, ..) => MsgType::ListRowPolicies
    Number(2403, ..) => MsgType::UpdateRowPolicy
    Number(2404, ..) => MsgType::SetRLSPrincipalTags
    Number(2405, ..) => MsgType::GetRLSPrincipalTags
    Number(2406, ..) => MsgType::ListRLSPrincipals
    Number(2407, ..) => MsgType::DeleteRLSPrincipalTags
    Number(2111, ..) => MsgType::GetExportSnapshotState
    Number(value, ..) =>
      if value.trunc() == value {
        MsgType::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for MsgType with fn to_json(self : MsgType) -> Json {
  match self {
    MsgType::Undefined => "Undefined"
    MsgType::CreateCollection => "CreateCollection"
    MsgType::DropCollection => "DropCollection"
    MsgType::HasCollection => "HasCollection"
    MsgType::DescribeCollection => "DescribeCollection"
    MsgType::ShowCollections => "ShowCollections"
    MsgType::GetSystemConfigs => "GetSystemConfigs"
    MsgType::LoadCollection => "LoadCollection"
    MsgType::ReleaseCollection => "ReleaseCollection"
    MsgType::CreateAlias => "CreateAlias"
    MsgType::DropAlias => "DropAlias"
    MsgType::AlterAlias => "AlterAlias"
    MsgType::AlterCollection => "AlterCollection"
    MsgType::RenameCollection => "RenameCollection"
    MsgType::DescribeAlias => "DescribeAlias"
    MsgType::ListAliases => "ListAliases"
    MsgType::AlterCollectionField => "AlterCollectionField"
    MsgType::AddCollectionFunction => "AddCollectionFunction"
    MsgType::AlterCollectionFunction => "AlterCollectionFunction"
    MsgType::DropCollectionFunction => "DropCollectionFunction"
    MsgType::TruncateCollection => "TruncateCollection"
    MsgType::SplitShard => "SplitShard"
    MsgType::CreatePartition => "CreatePartition"
    MsgType::DropPartition => "DropPartition"
    MsgType::HasPartition => "HasPartition"
    MsgType::DescribePartition => "DescribePartition"
    MsgType::ShowPartitions => "ShowPartitions"
    MsgType::LoadPartitions => "LoadPartitions"
    MsgType::ReleasePartitions => "ReleasePartitions"
    MsgType::ShowSegments => "ShowSegments"
    MsgType::DescribeSegment => "DescribeSegment"
    MsgType::LoadSegments => "LoadSegments"
    MsgType::ReleaseSegments => "ReleaseSegments"
    MsgType::HandoffSegments => "HandoffSegments"
    MsgType::LoadBalanceSegments => "LoadBalanceSegments"
    MsgType::DescribeSegments => "DescribeSegments"
    MsgType::FederListIndexedSegment => "FederListIndexedSegment"
    MsgType::FederDescribeSegmentIndexData => "FederDescribeSegmentIndexData"
    MsgType::CreateIndex => "CreateIndex"
    MsgType::DescribeIndex => "DescribeIndex"
    MsgType::DropIndex => "DropIndex"
    MsgType::GetIndexStatistics => "GetIndexStatistics"
    MsgType::AlterIndex => "AlterIndex"
    MsgType::Insert => "Insert"
    MsgType::Delete => "Delete"
    MsgType::Flush => "Flush"
    MsgType::ResendSegmentStats => "ResendSegmentStats"
    MsgType::Upsert => "Upsert"
    MsgType::ManualFlush => "ManualFlush"
    MsgType::FlushSegment => "FlushSegment"
    MsgType::CreateSegment => "CreateSegment"
    MsgType::Import => "Import"
    MsgType::FlushAll => "FlushAll"
    MsgType::Search => "Search"
    MsgType::SearchResult => "SearchResult"
    MsgType::GetIndexState => "GetIndexState"
    MsgType::GetIndexBuildProgress => "GetIndexBuildProgress"
    MsgType::GetCollectionStatistics => "GetCollectionStatistics"
    MsgType::GetPartitionStatistics => "GetPartitionStatistics"
    MsgType::Retrieve => "Retrieve"
    MsgType::RetrieveResult => "RetrieveResult"
    MsgType::WatchDmChannels => "WatchDmChannels"
    MsgType::RemoveDmChannels => "RemoveDmChannels"
    MsgType::WatchQueryChannels => "WatchQueryChannels"
    MsgType::RemoveQueryChannels => "RemoveQueryChannels"
    MsgType::SealedSegmentsChangeInfo => "SealedSegmentsChangeInfo"
    MsgType::WatchDeltaChannels => "WatchDeltaChannels"
    MsgType::GetShardLeaders => "GetShardLeaders"
    MsgType::GetReplicas => "GetReplicas"
    MsgType::UnsubDmChannel => "UnsubDmChannel"
    MsgType::GetDistribution => "GetDistribution"
    MsgType::SyncDistribution => "SyncDistribution"
    MsgType::RunAnalyzer => "RunAnalyzer"
    MsgType::SegmentInfo => "SegmentInfo"
    MsgType::SystemInfo => "SystemInfo"
    MsgType::GetRecoveryInfo => "GetRecoveryInfo"
    MsgType::GetSegmentState => "GetSegmentState"
    MsgType::TimeTick => "TimeTick"
    MsgType::QueryNodeStats => "QueryNodeStats"
    MsgType::LoadIndex => "LoadIndex"
    MsgType::RequestID => "RequestID"
    MsgType::RequestTSO => "RequestTSO"
    MsgType::AllocateSegment => "AllocateSegment"
    MsgType::SegmentStatistics => "SegmentStatistics"
    MsgType::SegmentFlushDone => "SegmentFlushDone"
    MsgType::DataNodeTt => "DataNodeTt"
    MsgType::Connect => "Connect"
    MsgType::ListClientInfos => "ListClientInfos"
    MsgType::AllocTimestamp => "AllocTimestamp"
    MsgType::Replicate => "Replicate"
    MsgType::CreateCredential => "CreateCredential"
    MsgType::GetCredential => "GetCredential"
    MsgType::DeleteCredential => "DeleteCredential"
    MsgType::UpdateCredential => "UpdateCredential"
    MsgType::ListCredUsernames => "ListCredUsernames"
    MsgType::CreateRole => "CreateRole"
    MsgType::DropRole => "DropRole"
    MsgType::OperateUserRole => "OperateUserRole"
    MsgType::SelectRole => "SelectRole"
    MsgType::SelectUser => "SelectUser"
    MsgType::SelectResource => "SelectResource"
    MsgType::OperatePrivilege => "OperatePrivilege"
    MsgType::SelectGrant => "SelectGrant"
    MsgType::RefreshPolicyInfoCache => "RefreshPolicyInfoCache"
    MsgType::ListPolicy => "ListPolicy"
    MsgType::CreatePrivilegeGroup => "CreatePrivilegeGroup"
    MsgType::DropPrivilegeGroup => "DropPrivilegeGroup"
    MsgType::ListPrivilegeGroups => "ListPrivilegeGroups"
    MsgType::OperatePrivilegeGroup => "OperatePrivilegeGroup"
    MsgType::OperatePrivilegeV2 => "OperatePrivilegeV2"
    MsgType::AlterRole => "AlterRole"
    MsgType::CreateResourceGroup => "CreateResourceGroup"
    MsgType::DropResourceGroup => "DropResourceGroup"
    MsgType::ListResourceGroups => "ListResourceGroups"
    MsgType::DescribeResourceGroup => "DescribeResourceGroup"
    MsgType::TransferNode => "TransferNode"
    MsgType::TransferReplica => "TransferReplica"
    MsgType::UpdateResourceGroups => "UpdateResourceGroups"
    MsgType::CreateDatabase => "CreateDatabase"
    MsgType::DropDatabase => "DropDatabase"
    MsgType::ListDatabases => "ListDatabases"
    MsgType::AlterDatabase => "AlterDatabase"
    MsgType::DescribeDatabase => "DescribeDatabase"
    MsgType::AddCollectionField => "AddCollectionField"
    MsgType::AlterWAL => "AlterWAL"
    MsgType::CreateSnapshot => "CreateSnapshot"
    MsgType::DropSnapshot => "DropSnapshot"
    MsgType::ListSnapshots => "ListSnapshots"
    MsgType::DescribeSnapshot => "DescribeSnapshot"
    MsgType::RestoreSnapshot => "RestoreSnapshot"
    MsgType::GetRestoreSnapshotState => "GetRestoreSnapshotState"
    MsgType::ListRestoreSnapshotJobs => "ListRestoreSnapshotJobs"
    MsgType::PinSnapshotData => "PinSnapshotData"
    MsgType::UnpinSnapshotData => "UnpinSnapshotData"
    MsgType::RestoreExternalSnapshot => "RestoreExternalSnapshot"
    MsgType::ExportSnapshot => "ExportSnapshot"
    MsgType::AlterCollectionSchema => "AlterCollectionSchema"
    MsgType::RefreshExternalCollection => "RefreshExternalCollection"
    MsgType::GetRefreshExternalCollectionProgress =>
      "GetRefreshExternalCollectionProgress"
    MsgType::ListRefreshExternalCollectionJobs =>
      "ListRefreshExternalCollectionJobs"
    MsgType::CreateRowPolicy => "CreateRowPolicy"
    MsgType::DropRowPolicy => "DropRowPolicy"
    MsgType::ListRowPolicies => "ListRowPolicies"
    MsgType::UpdateRowPolicy => "UpdateRowPolicy"
    MsgType::SetRLSPrincipalTags => "SetRLSPrincipalTags"
    MsgType::GetRLSPrincipalTags => "GetRLSPrincipalTags"
    MsgType::ListRLSPrincipals => "ListRLSPrincipals"
    MsgType::DeleteRLSPrincipalTags => "DeleteRLSPrincipalTags"
    MsgType::GetExportSnapshotState => "GetExportSnapshotState"
    MsgType::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) enum DslType {
  Dsl
  BoolExprV1
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn DslType::to_enum(self : DslType) -> @lib.Enum {
  match self {
    DslType::Dsl => 0
    DslType::BoolExprV1 => 1
    DslType::Unknown(value) => value
  }
}

///|
pub fn DslType::from_enum(i : @lib.Enum) -> DslType {
  match i.0 {
    0 => DslType::Dsl
    1 => DslType::BoolExprV1
    _ => DslType::Unknown(i)
  }
}

///|
pub impl Default for DslType with fn default() -> DslType {
  DslType::Dsl
}

///|
pub impl @lib.Sized for DslType with fn size_of(self : DslType) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for DslType with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DslType raise {
  match json {
    String("Dsl") => DslType::Dsl
    String("BoolExprV1") => DslType::BoolExprV1
    Number(0, ..) => DslType::Dsl
    Number(1, ..) => DslType::BoolExprV1
    Number(value, ..) =>
      if value.trunc() == value {
        DslType::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for DslType with fn to_json(self : DslType) -> Json {
  match self {
    DslType::Dsl => "Dsl"
    DslType::BoolExprV1 => "BoolExprV1"
    DslType::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) enum PlaceholderType {
  None
  BinaryVector
  FloatVector
  Float16Vector
  BFloat16Vector
  SparseFloatVector
  Int8Vector
  Int64
  VarChar
  EmbListBinaryVector
  EmbListFloatVector
  EmbListFloat16Vector
  EmbListBFloat16Vector
  EmbListSparseFloatVector
  EmbListInt8Vector
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn PlaceholderType::to_enum(self : PlaceholderType) -> @lib.Enum {
  match self {
    PlaceholderType::None => 0
    PlaceholderType::BinaryVector => 100
    PlaceholderType::FloatVector => 101
    PlaceholderType::Float16Vector => 102
    PlaceholderType::BFloat16Vector => 103
    PlaceholderType::SparseFloatVector => 104
    PlaceholderType::Int8Vector => 105
    PlaceholderType::Int64 => 5
    PlaceholderType::VarChar => 21
    PlaceholderType::EmbListBinaryVector => 300
    PlaceholderType::EmbListFloatVector => 301
    PlaceholderType::EmbListFloat16Vector => 302
    PlaceholderType::EmbListBFloat16Vector => 303
    PlaceholderType::EmbListSparseFloatVector => 304
    PlaceholderType::EmbListInt8Vector => 305
    PlaceholderType::Unknown(value) => value
  }
}

///|
pub fn PlaceholderType::from_enum(i : @lib.Enum) -> PlaceholderType {
  match i.0 {
    0 => PlaceholderType::None
    100 => PlaceholderType::BinaryVector
    101 => PlaceholderType::FloatVector
    102 => PlaceholderType::Float16Vector
    103 => PlaceholderType::BFloat16Vector
    104 => PlaceholderType::SparseFloatVector
    105 => PlaceholderType::Int8Vector
    5 => PlaceholderType::Int64
    21 => PlaceholderType::VarChar
    300 => PlaceholderType::EmbListBinaryVector
    301 => PlaceholderType::EmbListFloatVector
    302 => PlaceholderType::EmbListFloat16Vector
    303 => PlaceholderType::EmbListBFloat16Vector
    304 => PlaceholderType::EmbListSparseFloatVector
    305 => PlaceholderType::EmbListInt8Vector
    _ => PlaceholderType::Unknown(i)
  }
}

///|
pub impl Default for PlaceholderType with fn default() -> PlaceholderType {
  PlaceholderType::None
}

///|
pub impl @lib.Sized for PlaceholderType with fn size_of(self : PlaceholderType) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for PlaceholderType with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> PlaceholderType raise {
  match json {
    String("None") => PlaceholderType::None
    String("BinaryVector") => PlaceholderType::BinaryVector
    String("FloatVector") => PlaceholderType::FloatVector
    String("Float16Vector") => PlaceholderType::Float16Vector
    String("BFloat16Vector") => PlaceholderType::BFloat16Vector
    String("SparseFloatVector") => PlaceholderType::SparseFloatVector
    String("Int8Vector") => PlaceholderType::Int8Vector
    String("Int64") => PlaceholderType::Int64
    String("VarChar") => PlaceholderType::VarChar
    String("EmbListBinaryVector") => PlaceholderType::EmbListBinaryVector
    String("EmbListFloatVector") => PlaceholderType::EmbListFloatVector
    String("EmbListFloat16Vector") => PlaceholderType::EmbListFloat16Vector
    String("EmbListBFloat16Vector") => PlaceholderType::EmbListBFloat16Vector
    String("EmbListSparseFloatVector") =>
      PlaceholderType::EmbListSparseFloatVector
    String("EmbListInt8Vector") => PlaceholderType::EmbListInt8Vector
    Number(0, ..) => PlaceholderType::None
    Number(100, ..) => PlaceholderType::BinaryVector
    Number(101, ..) => PlaceholderType::FloatVector
    Number(102, ..) => PlaceholderType::Float16Vector
    Number(103, ..) => PlaceholderType::BFloat16Vector
    Number(104, ..) => PlaceholderType::SparseFloatVector
    Number(105, ..) => PlaceholderType::Int8Vector
    Number(5, ..) => PlaceholderType::Int64
    Number(21, ..) => PlaceholderType::VarChar
    Number(300, ..) => PlaceholderType::EmbListBinaryVector
    Number(301, ..) => PlaceholderType::EmbListFloatVector
    Number(302, ..) => PlaceholderType::EmbListFloat16Vector
    Number(303, ..) => PlaceholderType::EmbListBFloat16Vector
    Number(304, ..) => PlaceholderType::EmbListSparseFloatVector
    Number(305, ..) => PlaceholderType::EmbListInt8Vector
    Number(value, ..) =>
      if value.trunc() == value {
        PlaceholderType::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for PlaceholderType with fn to_json(self : PlaceholderType) -> Json {
  match self {
    PlaceholderType::None => "None"
    PlaceholderType::BinaryVector => "BinaryVector"
    PlaceholderType::FloatVector => "FloatVector"
    PlaceholderType::Float16Vector => "Float16Vector"
    PlaceholderType::BFloat16Vector => "BFloat16Vector"
    PlaceholderType::SparseFloatVector => "SparseFloatVector"
    PlaceholderType::Int8Vector => "Int8Vector"
    PlaceholderType::Int64 => "Int64"
    PlaceholderType::VarChar => "VarChar"
    PlaceholderType::EmbListBinaryVector => "EmbListBinaryVector"
    PlaceholderType::EmbListFloatVector => "EmbListFloatVector"
    PlaceholderType::EmbListFloat16Vector => "EmbListFloat16Vector"
    PlaceholderType::EmbListBFloat16Vector => "EmbListBFloat16Vector"
    PlaceholderType::EmbListSparseFloatVector => "EmbListSparseFloatVector"
    PlaceholderType::EmbListInt8Vector => "EmbListInt8Vector"
    PlaceholderType::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) enum WALName {
  Unknown
  RocksMQ
  Pulsar
  Kafka
  WoodPecker
  Test
  Unknown1(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn WALName::to_enum(self : WALName) -> @lib.Enum {
  match self {
    WALName::Unknown => 0
    WALName::RocksMQ => 1
    WALName::Pulsar => 2
    WALName::Kafka => 3
    WALName::WoodPecker => 4
    WALName::Test => 999
    WALName::Unknown1(value) => value
  }
}

///|
pub fn WALName::from_enum(i : @lib.Enum) -> WALName {
  match i.0 {
    0 => WALName::Unknown
    1 => WALName::RocksMQ
    2 => WALName::Pulsar
    3 => WALName::Kafka
    4 => WALName::WoodPecker
    999 => WALName::Test
    _ => WALName::Unknown1(i)
  }
}

///|
pub impl Default for WALName with fn default() -> WALName {
  WALName::Unknown
}

///|
pub impl @lib.Sized for WALName with fn size_of(self : WALName) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for WALName with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> WALName raise {
  match json {
    String("Unknown") => WALName::Unknown
    String("RocksMQ") => WALName::RocksMQ
    String("Pulsar") => WALName::Pulsar
    String("Kafka") => WALName::Kafka
    String("WoodPecker") => WALName::WoodPecker
    String("Test") => WALName::Test
    Number(0, ..) => WALName::Unknown
    Number(1, ..) => WALName::RocksMQ
    Number(2, ..) => WALName::Pulsar
    Number(3, ..) => WALName::Kafka
    Number(4, ..) => WALName::WoodPecker
    Number(999, ..) => WALName::Test
    Number(value, ..) =>
      if value.trunc() == value {
        WALName::Unknown1(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for WALName with fn to_json(self : WALName) -> Json {
  match self {
    WALName::Unknown => "Unknown"
    WALName::RocksMQ => "RocksMQ"
    WALName::Pulsar => "Pulsar"
    WALName::Kafka => "Kafka"
    WALName::WoodPecker => "WoodPecker"
    WALName::Test => "Test"
    WALName::Unknown1(value) => value.0.to_json()
  }
}

///|
pub(all) struct KeyDataPair {
  mut key : String
  mut data : Bytes
} derive(Eq, Debug)

///|
pub impl @lib.Sized for KeyDataPair with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  if self.data != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.data))
  }
  size
}

///|
pub impl Default for KeyDataPair with fn default() -> KeyDataPair {
  KeyDataPair::{ key: Default::default(), data: Default::default(), }
}

///|
#alias(new, deprecated)
pub fn KeyDataPair::KeyDataPair(key : String, data : Bytes) -> KeyDataPair {
  KeyDataPair::{ key, data, }
}

///|
pub impl @lib.Read for KeyDataPair with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> KeyDataPair raise {
  let msg : KeyDataPair = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.data = reader |> @lib.read_bytes()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for KeyDataPair with fn write(
  self : KeyDataPair,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  if self.data != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_bytes(self.data)
  }
}

///|
pub impl ToJson for KeyDataPair with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.data != Default::default() {
    json["data"] = @lib.base64_encode(self.data).to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for KeyDataPair with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> KeyDataPair raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for KeyDataPair"))
  }
  let message : KeyDataPair = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("data", String(value)) =>
        message.data = @lib.base64_decode(value) catch {
          _ => raise @json.JsonDecodeError((path, "Invalid base64 encoding"))
        }
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for KeyDataPair with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> KeyDataPair raise {
  let msg : KeyDataPair = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.data = reader |> @lib.async_read_bytes()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for KeyDataPair with fn write(
  self : KeyDataPair,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  if self.data != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_bytes(self.data)
  }
}

///|
pub(all) struct KeyValuePair {
  mut key : String
  mut value : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for KeyValuePair with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  if self.value != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.value))
  }
  size
}

///|
pub impl Default for KeyValuePair with fn default() -> KeyValuePair {
  KeyValuePair::{ key: Default::default(), value: Default::default(), }
}

///|
#alias(new, deprecated)
pub fn KeyValuePair::KeyValuePair(key : String, value : String) -> KeyValuePair {
  KeyValuePair::{ key, value, }
}

///|
pub impl @lib.Read for KeyValuePair with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> KeyValuePair raise {
  let msg : KeyValuePair = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for KeyValuePair with fn write(
  self : KeyValuePair,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.value)
  }
}

///|
pub impl ToJson for KeyValuePair with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for KeyValuePair with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> KeyValuePair raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for KeyValuePair"))
  }
  let message : KeyValuePair = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for KeyValuePair with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> KeyValuePair raise {
  let msg : KeyValuePair = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.value = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for KeyValuePair with fn write(
  self : KeyValuePair,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.value)
  }
}

///|
pub(all) struct MsgBase_PropertiesEntry {
  mut key : String
  mut value : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for MsgBase_PropertiesEntry with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  if self.value != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.value))
  }
  size
}

///|
pub impl Default for MsgBase_PropertiesEntry with fn default() -> MsgBase_PropertiesEntry {
  MsgBase_PropertiesEntry::{
    key: Default::default(),
    value: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn MsgBase_PropertiesEntry::MsgBase_PropertiesEntry(
  key : String,
  value : String,
) -> MsgBase_PropertiesEntry {
  MsgBase_PropertiesEntry::{ key, value, }
}

///|
pub impl @lib.Read for MsgBase_PropertiesEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> MsgBase_PropertiesEntry raise {
  let msg : MsgBase_PropertiesEntry = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for MsgBase_PropertiesEntry with fn write(
  self : MsgBase_PropertiesEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.value)
  }
}

///|
pub impl ToJson for MsgBase_PropertiesEntry with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for MsgBase_PropertiesEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> MsgBase_PropertiesEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for MsgBase_PropertiesEntry"),
    )
  }
  let message : MsgBase_PropertiesEntry = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for MsgBase_PropertiesEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> MsgBase_PropertiesEntry raise {
  let msg : MsgBase_PropertiesEntry = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.value = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for MsgBase_PropertiesEntry with fn write(
  self : MsgBase_PropertiesEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.value)
  }
}

///|
pub(all) struct MsgBase {
  mut msg_type : MsgType
  mut msg_id : Int64
  mut timestamp : UInt64
  mut source_id : Int64
  mut target_id : Int64
  mut properties : Map[String, String]
  mut replicate_info : ReplicateInfo?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for MsgBase with fn size_of(self) {
  let mut size = 0U
  if self.msg_type != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.msg_type))
  }
  if self.msg_id != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.msg_id))
  }
  if self.timestamp != Default::default() {
    size += @lib.size_of_field(3U, @lib.size_of(self.timestamp))
  }
  if self.source_id != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.source_id))
  }
  if self.target_id != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.target_id))
  }
  for k, v in self.properties {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(6U, key_size + value_size)
  }
  if self.replicate_info is Some(v) {
    size += @lib.size_of_length_delimited_field(7U, @lib.size_of(v))
  }
  size
}

///|
pub impl Default for MsgBase with fn default() -> MsgBase {
  MsgBase::{
    msg_type: Default::default(),
    msg_id: Default::default(),
    timestamp: Default::default(),
    source_id: Default::default(),
    target_id: Default::default(),
    properties: {},
    replicate_info: None,
  }
}

///|
#alias(new, deprecated)
pub fn MsgBase::MsgBase(
  msg_type : MsgType,
  msg_id : Int64,
  timestamp : UInt64,
  source_id : Int64,
  target_id : Int64,
  properties : Map[String, String],
  replicate_info? : ReplicateInfo,
) -> MsgBase {
  MsgBase::{
    msg_type,
    msg_id,
    timestamp,
    source_id,
    target_id,
    properties,
    replicate_info,
  }
}

///|
pub impl @lib.Read for MsgBase with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> MsgBase raise {
  let msg : MsgBase = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.msg_type = reader |> @lib.read_enum() |> MsgType::from_enum
      (2, _) => msg.msg_id = reader |> @lib.read_int64()
      (3, _) => msg.timestamp = reader |> @lib.read_uint64()
      (4, _) => msg.source_id = reader |> @lib.read_int64()
      (5, _) => msg.target_id = reader |> @lib.read_int64()
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.read_message() : MsgBase_PropertiesEntry)
        msg.properties[key] = value
      }
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.replicate_info = (reader |> @lib.read_message() : ReplicateInfo)
          |> Some
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for MsgBase with fn write(
  self : MsgBase,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.msg_type != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_enum(self.msg_type.to_enum())
  }
  if self.msg_id != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(self.msg_id)
  }
  if self.timestamp != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_uint64(self.timestamp)
  }
  if self.source_id != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_int64(self.source_id)
  }
  if self.target_id != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_int64(self.target_id)
  }
  let keys = self.properties.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.properties.get(k).unwrap()
    writer |> @lib.write_varint(50UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(v)
  }
  if self.replicate_info is Some(v) {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_message(v)
  }
}

///|
pub impl ToJson for MsgBase with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.msg_type != Default::default() {
    json["msgType"] = ToJson::to_json(self.msg_type)
  }
  if self.msg_id != Default::default() {
    json["msgID"] = ToJson::to_json(self.msg_id)
  }
  if self.timestamp != Default::default() {
    json["timestamp"] = ToJson::to_json(self.timestamp)
  }
  if self.source_id != Default::default() {
    json["sourceID"] = ToJson::to_json(self.source_id)
  }
  if self.target_id != Default::default() {
    json["targetID"] = ToJson::to_json(self.target_id)
  }
  if self.properties != Default::default() {
    json["properties"] = ToJson::to_json(self.properties)
  }
  match self.replicate_info {
    Some(v) => json["replicateInfo"] = ToJson::to_json(v)
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for MsgBase with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> MsgBase raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for MsgBase"))
  }
  let message : MsgBase = Default::default()
  for key, value in obj {
    match (key, value) {
      ("msgType", value) => message.msg_type = @json.from_json(value, path~)
      ("msgID", value) => message.msg_id = @json.from_json(value, path~)
      ("timestamp", value) => message.timestamp = @json.from_json(value, path~)
      ("sourceID", value) => message.source_id = @json.from_json(value, path~)
      ("targetID", value) => message.target_id = @json.from_json(value, path~)
      ("properties", _) => message.properties = @json.from_json(value, path~)
      ("replicateInfo", value) =>
        message.replicate_info = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for MsgBase with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> MsgBase raise {
  let msg : MsgBase = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.msg_type = reader |> @lib.async_read_enum() |> MsgType::from_enum
      (2, _) => msg.msg_id = reader |> @lib.async_read_int64()
      (3, _) => msg.timestamp = reader |> @lib.async_read_uint64()
      (4, _) => msg.source_id = reader |> @lib.async_read_int64()
      (5, _) => msg.target_id = reader |> @lib.async_read_int64()
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.async_read_message() : MsgBase_PropertiesEntry)
        msg.properties[key] = value
      }
      (7, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.replicate_info = (
            reader |> @lib.async_read_message() : ReplicateInfo)
          |> Some
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for MsgBase with fn write(
  self : MsgBase,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.msg_type != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_enum(self.msg_type.to_enum())
  }
  if self.msg_id != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(self.msg_id)
  }
  if self.timestamp != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_uint64(self.timestamp)
  }
  if self.source_id != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_int64(self.source_id)
  }
  if self.target_id != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_int64(self.target_id)
  }
  let keys = self.properties.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.properties.get(k).unwrap()
    writer |> @lib.async_write_varint(50UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(v)
  }
  if self.replicate_info is Some(v) {
    writer |> @lib.async_write_varint(58UL)
    writer |> @lib.async_write_message(v)
  }
}

///|
pub(all) struct ReplicateInfo {
  mut is_replicate : Bool
  mut msg_timestamp : UInt64
  mut replicate_id : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for ReplicateInfo with fn size_of(self) {
  let mut size = 0U
  if self.is_replicate != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.is_replicate))
  }
  if self.msg_timestamp != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.msg_timestamp))
  }
  if self.replicate_id != Default::default() {
    size += @lib.size_of_length_delimited_field(
      3U,
      @lib.size_of(self.replicate_id),
    )
  }
  size
}

///|
pub impl Default for ReplicateInfo with fn default() -> ReplicateInfo {
  ReplicateInfo::{
    is_replicate: Default::default(),
    msg_timestamp: Default::default(),
    replicate_id: Default::default(),
  }
}

///|
#alias(new, deprecated)
pub fn ReplicateInfo::ReplicateInfo(
  is_replicate : Bool,
  msg_timestamp : UInt64,
  replicate_id : String,
) -> ReplicateInfo {
  ReplicateInfo::{ is_replicate, msg_timestamp, replicate_id, }
}

///|
pub impl @lib.Read for ReplicateInfo with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ReplicateInfo raise {
  let msg : ReplicateInfo = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.is_replicate = reader |> @lib.read_bool()
      (2, _) => msg.msg_timestamp = reader |> @lib.read_uint64()
      (3, _) => msg.replicate_id = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ReplicateInfo with fn write(
  self : ReplicateInfo,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.is_replicate != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_bool(self.is_replicate)
  }
  if self.msg_timestamp != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_uint64(self.msg_timestamp)
  }
  if self.replicate_id != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.replicate_id)
  }
}

///|
pub impl ToJson for ReplicateInfo with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.is_replicate != Default::default() {
    json["isReplicate"] = ToJson::to_json(self.is_replicate)
  }
  if self.msg_timestamp != Default::default() {
    json["msgTimestamp"] = ToJson::to_json(self.msg_timestamp)
  }
  if self.replicate_id != Default::default() {
    json["replicateID"] = ToJson::to_json(self.replicate_id)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ReplicateInfo with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ReplicateInfo raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ReplicateInfo"))
  }
  let message : ReplicateInfo = Default::default()
  for key, value in obj {
    match (key, value) {
      ("isReplicate", value) =>
        message.is_replicate = @json.from_json(value, path~)
      ("msgTimestamp", value) =>
        message.msg_timestamp = @json.from_json(value, path~)
      ("replicateID", value) =>
        message.replicate_id = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ReplicateInfo with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ReplicateInfo raise {
  let msg : ReplicateInfo = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.is_replicate = reader |> @lib.async_read_bool()
      (2, _) => msg.msg_timestamp = reader |> @lib.async_read_uint64()
      (3, _) => msg.replicate_id = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ReplicateInfo with fn write(
  self : ReplicateInfo,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.is_replicate != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_bool(self.is_replicate)
  }
  if self.msg_timestamp != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_uint64(self.msg_timestamp)
  }
  if self.replicate_id != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.replicate_id)
  }
}

///|
pub(all) struct Status_ExtraInfoEntry {
  mut key : String
  mut value : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Status_ExtraInfoEntry with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  if self.value != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.value))
  }
  size
}

///|
pub impl Default for Status_ExtraInfoEntry with fn default() -> Status_ExtraInfoEntry {
  Status_ExtraInfoEntry::{ key: Default::default(), value: Default::default(), }
}

///|
#alias(new, deprecated)
pub fn Status_ExtraInfoEntry::Status_ExtraInfoEntry(
  key : String,
  value : String,
) -> Status_ExtraInfoEntry {
  Status_ExtraInfoEntry::{ key, value, }
}

///|
pub impl @lib.Read for Status_ExtraInfoEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Status_ExtraInfoEntry raise {
  let msg : Status_ExtraInfoEntry = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Status_ExtraInfoEntry with fn write(
  self : Status_ExtraInfoEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.value)
  }
}

///|
pub impl ToJson for Status_ExtraInfoEntry with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.key != Default::default() {
    json["key"] = ToJson::to_json(self.key)
  }
  if self.value != Default::default() {
    json["value"] = ToJson::to_json(self.value)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Status_ExtraInfoEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Status_ExtraInfoEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for Status_ExtraInfoEntry"),
    )
  }
  let message : Status_ExtraInfoEntry = Default::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Status_ExtraInfoEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Status_ExtraInfoEntry raise {
  let msg : Status_ExtraInfoEntry = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.value = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Status_ExtraInfoEntry with fn write(
  self : Status_ExtraInfoEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.value)
  }
}

///|
pub(all) struct Status {
  mut error_code : ErrorCode
  mut reason : String
  mut code : Int
  mut retriable : Bool
  mut detail : String
  mut extra_info : Map[String, String]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Status with fn size_of(self) {
  let mut size = 0U
  if self.error_code != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.error_code))
  }
  if self.reason != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.reason))
  }
  if self.code != Default::default() {
    size += @lib.size_of_field(3U, @lib.size_of(self.code))
  }
  if self.retriable != Default::default() {
    size += @lib.size_of_field(4U, @lib.size_of(self.retriable))
  }
  if self.detail != Default::default() {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(self.detail))
  }
  for k, v in self.extra_info {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(6U, key_size + value_size)
  }
  size
}

///|
pub impl Default for Status with fn default() -> Status {
  Status::{
    error_code: Default::default(),
    reason: Default::default(),
    code: Default::default(),
    retriable: Default::default(),
    detail: Default::default(),
    extra_info: {},
  }
}

///|
#alias(new, deprecated)
pub fn Status::Status(
  error_code : ErrorCode,
  reason : String,
  code : Int,
  retriable : Bool,
  detail : String,
  extra_info : Map[String, String],
) -> Status {
  Status::{ error_code, reason, code, retriable, detail, extra_info, }
}

///|
pub impl @lib.Read for Status with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Status raise {
  let msg : Status = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.error_code = reader |> @lib.read_enum() |> ErrorCode::from_enum
      (2, _) => msg.reason = reader |> @lib.read_string()
      (3, _) => msg.code = reader |> @lib.read_int32()
      (4, _) => msg.retriable = reader |> @lib.read_bool()
      (5, _) => msg.detail = reader |> @lib.read_string()
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.read_message() : Status_ExtraInfoEntry)
        msg.extra_info[key] = value
      }
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Status with fn write(
  self : Status,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.error_code != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_enum(self.error_code.to_enum())
  }
  if self.reason != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.reason)
  }
  if self.code != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_int32(self.code)
  }
  if self.retriable != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_bool(self.retriable)
  }
  if self.detail != Default::default() {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(self.detail)
  }
  let keys = self.extra_info.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.extra_info.get(k).unwrap()
    writer |> @lib.write_varint(50UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(v)
  }
}

///|
pub impl ToJson for Status with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.error_code != Default::default() {
    json["errorCode"] = ToJson::to_json(self.error_code)
  }
  if self.reason != Default::default() {
    json["reason"] = ToJson::to_json(self.reason)
  }
  if self.code != Default::default() {
    json["code"] = ToJson::to_json(self.code)
  }
  if self.retriable != Default::default() {
    json["retriable"] = ToJson::to_json(self.retriable)
  }
  if self.detail != Default::default() {
    json["detail"] = ToJson::to_json(self.detail)
  }
  if self.extra_info != Default::default() {
    json["extraInfo"] = ToJson::to_json(self.extra_info)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Status with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Status raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Status"))
  }
  let message : Status = Default::default()
  for key, value in obj {
    match (key, value) {
      ("errorCode", value) => message.error_code = @json.from_json(value, path~)
      ("reason", value) => message.reason = @json.from_json(value, path~)
      ("code", value) => message.code = @json.from_json(value, path~)
      ("retriable", value) => message.retriable = @json.from_json(value, path~)
      ("detail", value) => message.detail = @json.from_json(value, path~)
      ("extraInfo", _) => message.extra_info = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Status with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Status raise {
  let msg : Status = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.error_code = reader
          |> @lib.async_read_enum()
          |> ErrorCode::from_enum
      (2, _) => msg.reason = reader |> @lib.async_read_string()
      (3, _) => msg.code = reader |> @lib.async_read_int32()
      (4, _) => msg.retriable = reader |> @lib.async_read_bool()
      (5, _) => msg.detail = reader |> @lib.async_read_string()
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) => {
        let { key, value, } = (
          reader |> @lib.async_read_message() : Status_ExtraInfoEntry)
        msg.extra_info[key] = value
      }
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Status with fn write(
  self : Status,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.error_code != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_enum(self.error_code.to_enum())
  }
  if self.reason != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.reason)
  }
  if self.code != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_int32(self.code)
  }
  if self.retriable != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_bool(self.retriable)
  }
  if self.detail != Default::default() {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_string(self.detail)
  }
  let keys = self.extra_info.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.extra_info.get(k).unwrap()
    writer |> @lib.async_write_varint(50UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(v)
  }
}

///|
pub(all) struct PlaceholderValue {
  mut tag : String
  mut type_ : PlaceholderType
  mut values : Array[Bytes]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for PlaceholderValue with fn size_of(self) {
  let mut size = 0U
  if self.tag != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.tag))
  }
  if self.type_ != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.type_))
  }
  for s in self.values {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for PlaceholderValue with fn default() -> PlaceholderValue {
  PlaceholderValue::{
    tag: Default::default(),
    type_: Default::default(),
    values: [],
  }
}

///|
#alias(new, deprecated)
pub fn PlaceholderValue::PlaceholderValue(
  tag : String,
  type_ : PlaceholderType,
  values : Array[Bytes],
) -> PlaceholderValue {
  PlaceholderValue::{ tag, type_, values, }
}

///|
pub impl @lib.Read for PlaceholderValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> PlaceholderValue raise {
  let msg : PlaceholderValue = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.tag = reader |> @lib.read_string()
      (2, _) =>
        msg.type_ = reader |> @lib.read_enum() |> PlaceholderType::from_enum
      (3, _) => msg.values.push(reader |> @lib.read_bytes())
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for PlaceholderValue with fn write(
  self : PlaceholderValue,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.tag != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.tag)
  }
  if self.type_ != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_enum(self.type_.to_enum())
  }
  for item in self.values {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_bytes(item)
  }
}

///|
pub impl ToJson for PlaceholderValue with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.tag != Default::default() {
    json["tag"] = ToJson::to_json(self.tag)
  }
  if self.type_ != Default::default() {
    json["type"] = ToJson::to_json(self.type_)
  }
  if self.values != Default::default() {
    json["values"] = self.values.map(@lib.base64_encode).to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for PlaceholderValue with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> PlaceholderValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for PlaceholderValue"),
    )
  }
  let message : PlaceholderValue = Default::default()
  for key, value in obj {
    match (key, value) {
      ("tag", value) => message.tag = @json.from_json(value, path~)
      ("type", value) => message.type_ = @json.from_json(value, path~)
      ("values", Array(value)) =>
        message.values = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for PlaceholderValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> PlaceholderValue raise {
  let msg : PlaceholderValue = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.tag = reader |> @lib.async_read_string()
      (2, _) =>
        msg.type_ = reader
          |> @lib.async_read_enum()
          |> PlaceholderType::from_enum
      (3, _) => msg.values.push(reader |> @lib.async_read_bytes())
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for PlaceholderValue with fn write(
  self : PlaceholderValue,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.tag != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.tag)
  }
  if self.type_ != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_enum(self.type_.to_enum())
  }
  for item in self.values {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_bytes(item)
  }
}

///|
pub(all) struct PlaceholderGroup {
  mut placeholders : Array[PlaceholderValue]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for PlaceholderGroup with fn size_of(self) {
  let mut size = 0U
  for s in self.placeholders {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for PlaceholderGroup with fn default() -> PlaceholderGroup {
  PlaceholderGroup::{ placeholders: [], }
}

///|
#alias(new, deprecated)
pub fn PlaceholderGroup::PlaceholderGroup(
  placeholders : Array[PlaceholderValue],
) -> PlaceholderGroup {
  PlaceholderGroup::{ placeholders, }
}

///|
pub impl @lib.Read for PlaceholderGroup with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> PlaceholderGroup raise {
  let msg : PlaceholderGroup = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.placeholders.push(
          (reader |> @lib.read_message() : PlaceholderValue),
        )
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for PlaceholderGroup with fn write(
  self : PlaceholderGroup,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.placeholders {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(item)
  }
}

///|
pub impl ToJson for PlaceholderGroup with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.placeholders != Default::default() {
    json["placeholders"] = ToJson::to_json(self.placeholders)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for PlaceholderGroup with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> PlaceholderGroup raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for PlaceholderGroup"),
    )
  }
  let message : PlaceholderGroup = Default::default()
  for key, value in obj {
    match (key, value) {
      ("placeholders", Array(value)) =>
        message.placeholders = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for PlaceholderGroup with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> PlaceholderGroup raise {
  let msg : PlaceholderGroup = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.placeholders.push(
          (reader |> @lib.async_read_message() : PlaceholderValue),
        )
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for PlaceholderGroup with fn write(
  self : PlaceholderGroup,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.placeholders {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(item)
  }
}
