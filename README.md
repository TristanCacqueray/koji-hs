# Koji XMLRPC binding for Haskell

[![Build status](https://img.shields.io/travis/juhp/koji-hs.svg?logo=travis)](https://travis-ci.org/juhp/koji-hs)
[![Hackage](https://img.shields.io/hackage/v/koji.svg?logo=haskell)](https://hackage.haskell.org/package/koji)
[![Stackage Lts](http://stackage.org/package/koji/badge/lts)](http://stackage.org/lts/package/koji)
[![Stackage Nightly](http://stackage.org/package/koji/badge/nightly)](http://stackage.org/nightly/package/koji)
[![GPL-2 license](https://img.shields.io/badge/license-GPL--2-blue.svg)](LICENSE)

This is a WIP: currently only querying koji working,
ie not login or building etc.

## Installation

Build with `stack` or `cabal new-build`.

## Usage

I believe due to haxr using HsOpenSSL, programs using this library
need to be linked with `ghc-options: -threaded`, otherwise
the RTS will complain with an error.
