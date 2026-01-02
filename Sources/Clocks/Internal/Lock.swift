// Lock.swift
// Clocks
//
// Foundation-free locking primitive for thread-safe clock state.

#if canImport(Darwin)
    import Darwin

    final class Lock: @unchecked Sendable {
        private var _lock = os_unfair_lock()

        init() {}

        @discardableResult
        func sync<R>(_ body: () throws -> R) rethrows -> R {
            os_unfair_lock_lock(&_lock)
            defer { os_unfair_lock_unlock(&_lock) }
            return try body()
        }
    }

    final class RecursiveLock: @unchecked Sendable {
        private var _lock: pthread_mutex_t

        init() {
            _lock = pthread_mutex_t()
            var attr = pthread_mutexattr_t()
            pthread_mutexattr_init(&attr)
            pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
            pthread_mutex_init(&_lock, &attr)
            pthread_mutexattr_destroy(&attr)
        }

        deinit {
            pthread_mutex_destroy(&_lock)
        }

        @discardableResult
        func sync<R>(_ body: () throws -> R) rethrows -> R {
            pthread_mutex_lock(&_lock)
            defer { pthread_mutex_unlock(&_lock) }
            return try body()
        }
    }

#elseif canImport(Glibc) || canImport(Musl)
    #if canImport(Glibc)
        import Glibc
    #else
        import Musl
    #endif

    final class Lock: @unchecked Sendable {
        private var _lock = pthread_mutex_t()

        init() {
            pthread_mutex_init(&_lock, nil)
        }

        deinit {
            pthread_mutex_destroy(&_lock)
        }

        @discardableResult
        func sync<R>(_ body: () throws -> R) rethrows -> R {
            pthread_mutex_lock(&_lock)
            defer { pthread_mutex_unlock(&_lock) }
            return try body()
        }
    }

    final class RecursiveLock: @unchecked Sendable {
        private var _lock: pthread_mutex_t

        init() {
            _lock = pthread_mutex_t()
            var attr = pthread_mutexattr_t()
            pthread_mutexattr_init(&attr)
            pthread_mutexattr_settype(&attr, Int32(PTHREAD_MUTEX_RECURSIVE))
            pthread_mutex_init(&_lock, &attr)
            pthread_mutexattr_destroy(&attr)
        }

        deinit {
            pthread_mutex_destroy(&_lock)
        }

        @discardableResult
        func sync<R>(_ body: () throws -> R) rethrows -> R {
            pthread_mutex_lock(&_lock)
            defer { pthread_mutex_unlock(&_lock) }
            return try body()
        }
    }

#elseif os(Windows)
    import WinSDK

    final class Lock: @unchecked Sendable {
        private var _lock = SRWLOCK()

        init() {
            InitializeSRWLock(&_lock)
        }

        @discardableResult
        func sync<R>(_ body: () throws -> R) rethrows -> R {
            AcquireSRWLockExclusive(&_lock)
            defer { ReleaseSRWLockExclusive(&_lock) }
            return try body()
        }
    }

    final class RecursiveLock: @unchecked Sendable {
        private var _lock = CRITICAL_SECTION()

        init() {
            InitializeCriticalSection(&_lock)
        }

        deinit {
            DeleteCriticalSection(&_lock)
        }

        @discardableResult
        func sync<R>(_ body: () throws -> R) rethrows -> R {
            EnterCriticalSection(&_lock)
            defer { LeaveCriticalSection(&_lock) }
            return try body()
        }
    }
#endif
