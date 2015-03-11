/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x8ef4fb42 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "//buis.isim.intra/daniel.souza$/NerfFantome/Master.vhd";



static void work_a_0626639344_3212880686_p_0(char *t0)
{
    char *t1;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    xsi_set_current_line(53, ng0);
    t1 = (t0 + 2842);
    t3 = (t0 + 1676);
    t4 = (t3 + 32U);
    t5 = *((char **)t4);
    t6 = (t5 + 40U);
    t7 = *((char **)t6);
    memcpy(t7, t1, 12U);
    xsi_driver_first_trans_fast_port(t3);
    t1 = (t0 + 1632);
    *((int *)t1) = 1;

LAB1:    return;
}


extern void work_a_0626639344_3212880686_init()
{
	static char *pe[] = {(void *)work_a_0626639344_3212880686_p_0};
	xsi_register_didat("work_a_0626639344_3212880686", "isim/MasterTest_isim_beh.exe.sim/work/a_0626639344_3212880686.didat");
	xsi_register_executes(pe);
}
