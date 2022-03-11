/*
 * NASA Docket No. GSC-18,587-1 and identified as “The Bundle Protocol Core Flight
 * System Application (BP) v6.5”
 *
 * Copyright © 2020 United States Government as represented by the Administrator of
 * the National Aeronautics and Space Administration. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#ifndef CTEB_H
#define CTEB_H

/******************************************************************************
 INCLUDES
 ******************************************************************************/

#include "bplib.h"
#include "bundle_types.h"

/******************************************************************************
 TYPEDEFS
 ******************************************************************************/

typedef struct
{
    bp_field_t bf;                        /* block flags */
    bp_field_t blklen;                    /* block length */
    bp_field_t cid;                       /* custody ID */
    char       csteid[BP_MAX_EID_STRING]; /* custody EID: "ipn:{node}.{service}" */
    bp_ipn_t   cstnode;                   /* custody node */
    bp_ipn_t   cstserv;                   /* custody service */
} bp_blk_cteb_t;

/******************************************************************************
 PROTOTYPES
 ******************************************************************************/

int cteb_read(const void *block, int size, bp_blk_cteb_t *cteb, bool update_indices, uint32_t *flags);
int cteb_write(void *block, int size, bp_blk_cteb_t *cteb, bool update_indices, uint32_t *flags);

#endif /* CTEB_H */
