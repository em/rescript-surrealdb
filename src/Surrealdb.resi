module Api: {
  module Client = Surrealdb_Api
  module Promise = Surrealdb_ApiPromise
  module Response = Surrealdb_ApiResponse
}

module Connection: {
  module Auth = Surrealdb_Auth
  module DriverContext = Surrealdb_DriverContext
  module DriverOptions = Surrealdb_DriverOptions
  module Engine = Surrealdb_Engine
  module Feature = Surrealdb_Feature
  module Features = Surrealdb_Features
  module HttpEngine = Surrealdb_HttpEngine
  module Queryable = Surrealdb_Queryable
  module RemoteEngines = Surrealdb_RemoteEngines
  module RpcEngine = Surrealdb_RpcEngine
  module Session = Surrealdb_Session
  module Surreal = Surrealdb_Surreal
  module Transaction = Surrealdb_Transaction
  module VersionInfo = Surrealdb_VersionInfo
  module VersionSupport = Surrealdb_VersionSupport
  module WebSocketEngine = Surrealdb_WebSocketEngine
}

module Errors: {
  module Client = Surrealdb_ClientError
  module Error = Surrealdb_Error
  module ErrorKind = Surrealdb_ErrorKind
  module ErrorPayload = Surrealdb_ErrorPayload
  module Server = Surrealdb_ServerError
  module Surreal = Surrealdb_SurrealError
}

module Live: {
  module Actions = Surrealdb_LiveActions
  module Builder = Surrealdb_Live
  module ChannelIterator = Surrealdb_ChannelIterator
  module DoneFrame = Surrealdb_Frame
  module ManagedSubscription = Surrealdb_ManagedLiveSubscription
  module Message = Surrealdb_LiveMessage
  module Publisher = Surrealdb_Publisher
  module Subscription = Surrealdb_LiveSubscription
  module UnmanagedSubscription = Surrealdb_UnmanagedLiveSubscription
}

module Query: {
  module Bound = Surrealdb_BoundQuery
  module Create = Surrealdb_Create
  module Delete = Surrealdb_Delete
  module Export = Surrealdb_Export
  module Expr = Surrealdb_Expr
  module Insert = Surrealdb_Insert
  module Output = Surrealdb_Output
  module Query = Surrealdb_Query
  module QueryFrame = Surrealdb_QueryFrame
  module QueryResponse = Surrealdb_QueryResponse
  module QueryStats = Surrealdb_QueryStats
  module Relate = Surrealdb_Relate
  module Run = Surrealdb_Run
  module Select = Surrealdb_Select
  module Surql = Surrealdb_Surql
  module Update = Surrealdb_Update
  module Upsert = Surrealdb_Upsert
}

module Support: {
  module AsyncIterable = Surrealdb_AsyncIterable
  module Equals = Surrealdb_Equals
  module Escape = Surrealdb_Escape
  module Jsonify = Surrealdb_Jsonify
  module JsValue = Surrealdb_JsValue
  module Tokens = Surrealdb_Tokens
}

module Values: {
  module BoundValue = Surrealdb_BoundValue
  module CborCodec = Surrealdb_CborCodec
  module DateTime = Surrealdb_DateTime
  module Decimal = Surrealdb_Decimal
  module Duration = Surrealdb_Duration
  module FileRef = Surrealdb_FileRef
  module Future = Surrealdb_Future
  module Geometry = Surrealdb_Geometry
  module GeometryCollection = Surrealdb_GeometryCollection
  module GeometryLine = Surrealdb_GeometryLine
  module GeometryMultiLine = Surrealdb_GeometryMultiLine
  module GeometryMultiPoint = Surrealdb_GeometryMultiPoint
  module GeometryMultiPolygon = Surrealdb_GeometryMultiPolygon
  module GeometryPoint = Surrealdb_GeometryPoint
  module GeometryPolygon = Surrealdb_GeometryPolygon
  module Range = Surrealdb_Range
  module RangeBound = Surrealdb_RangeBound
  module RecordId = Surrealdb_RecordId
  module RecordIdRange = Surrealdb_RecordIdRange
  module StringRecordId = Surrealdb_StringRecordId
  module Table = Surrealdb_Table
  module Uuid = Surrealdb_Uuid
  module Value = Surrealdb_Value
  module ValueClass = Surrealdb_ValueClass
  module ValueCodec = Surrealdb_ValueCodec
}
