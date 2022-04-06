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

/******************************************************************************
 INCLUDES
 ******************************************************************************/

#include "ut_assert.h"
#include "bplib_store_flash.h"
#include "bplib_flash_sim.h"
#include "lrc.h"

/******************************************************************************
 DEFINES
 ******************************************************************************/

#define TEST_PAGE_DATA_SIZE FLASH_SIM_PAGE_SIZE
#if TEST_PAGE_DATA_SIZE > FLASH_SIM_PAGE_SIZE
#error "Test page data size exceeds physical size of flash simulation page data size"
#endif

#define TEST_DATA_SIZE (TEST_PAGE_DATA_SIZE * 3 + 200)
#define NUM_BUNDLES    200

/******************************************************************************
 EXTERNAL PROTOTYPES
 ******************************************************************************/

extern int flash_free_reclaim(bp_flash_index_t block);
extern int flash_free_allocate(bp_flash_index_t *block);
extern int flash_data_write(bp_flash_addr_t *addr, uint8_t *data, int size);
extern int flash_data_read(bp_flash_addr_t *addr, uint8_t *data, int size);

/******************************************************************************
 FILE DATA
 ******************************************************************************/

static bp_flash_driver_t flash_driver = {.num_blocks      = FLASH_SIM_NUM_BLOCKS,
                                         .pages_per_block = FLASH_SIM_PAGES_PER_BLOCK,
                                         .page_size       = TEST_PAGE_DATA_SIZE,
                                         .read            = bplib_flash_sim_page_read,
                                         .write           = bplib_flash_sim_page_write,
                                         .erase           = bplib_flash_sim_block_erase,
                                         .isbad           = bplib_flash_sim_block_is_bad,
                                         .phyblk          = bplib_flash_sim_physical_block};

static uint8_t test_data[TEST_DATA_SIZE], read_data[TEST_DATA_SIZE];


/******************************************************************************
 EXPORTED FUNCTIONS
 ******************************************************************************/

int ut_flash(void)
{
    ut_reset();

    /* Global Setup */

    bplib_flash_sim_initialize();

    /* Clean Up */

    bplib_flash_sim_uninitialize();

    return ut_failures();
}