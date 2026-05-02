/* Portions Copyright (c) 2025 Mario Zechner (MIT License).
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */


/**
 * Utility functions for Amazon Bedrock tests
 */

/**
 * Check if any valid AWS credentials are configured for Bedrock.
 * Returns true if any of the following are set:
 * - AWS_PROFILE (named profile from ~/.aws/credentials)
 * - AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY (IAM keys)
 * - AWS_BEARER_TOKEN_BEDROCK (Bedrock API key)
 */
export function hasBedrockCredentials(): boolean {
	return !!(
		process.env.AWS_PROFILE ||
		(process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) ||
		process.env.AWS_BEARER_TOKEN_BEDROCK
	);
}
