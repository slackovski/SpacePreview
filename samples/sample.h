#pragma once

#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/** Opaque handle to a user session. */
typedef struct UserSession UserSession;

/**
 * Create a new user session.
 * @param user_id  Unique identifier for the user.
 * @param token    Authentication token (null-terminated string).
 * @return New session handle, or NULL on allocation failure.
 */
UserSession *session_create(int64_t user_id, const char *token);

/**
 * Destroy a session and free all associated resources.
 * After this call the pointer is invalid.
 */
void session_destroy(UserSession *session);

/** Returns true if the session token is still valid. */
bool session_is_valid(const UserSession *session);

/** Returns the user ID stored in the session. */
int64_t session_user_id(const UserSession *session);

#ifdef __cplusplus
}
#endif
