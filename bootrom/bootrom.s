/*
 * allwinner f1c100s bootrom for qemu
 *
 * a simple bios
 *
 * Copyright (c) 2023 Lu Hui <luhux76@gmail.com>
 * some code from mainline uboot:
 * arch/arm/cpu/arm926ejs/start.S
 *  Copyright (c) 2003  Texas Instruments
 *
 *  ----- Adapted for OMAP1610 OMAP730 from ARM925t code ------
 *
 *  Copyright (c) 2001  Marius Gröger <mag@sysgo.de>
 *  Copyright (c) 2002  Alex Züpke <azu@sysgo.de>
 *  Copyright (c) 2002  Gary Jennejohn <garyj@denx.de>
 *  Copyright (c) 2003  Richard Woodruff <r-woodruff2@ti.com>
 *  Copyright (c) 2003  Kshitij <kshitij@ti.com>
 *  Copyright (c) 2010  Albert Aribaud <albert.u.boot@aribaud.net>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 */

/*
 * reference:
 * https://github.com/allwinner-zh/bootloader
 * https://linux-sunxi.org/BROM
 * https://developer.arm.com/documentation/ddi0198/e/
 * https://courses.cs.washington.edu/courses/cse466/10au/pdfs/lectures/07-arm_overview.pdf
 */

.global _start
_start:

vector:
	b reset
	ldr pc, _undefined_instruction
	ldr pc, _software_interrupt
	ldr pc, _prefetch_abort
	ldr pc, _data_abort
	ldr pc, _not_used
	ldr pc, _irq
	ldr pc, _fiq

_undefined_instruction: .word undefined_instruction
_software_interrupt:    .word software_interrupt
_prefetch_abort:        .word prefetch_abort
_data_abort:            .word data_abort
_not_used:              .word not_used
_irq:                   .word irq
_fiq:                   .word fiq

	.align 5
undefined_instruction:
software_interrupt:
prefetch_abort:
data_abort:
not_used:
irq:
fiq:
1:
	b 1b /* hang */



reset:
	mrs r0, cpsr
	/* enter svc mode */
	bic r0, r0, #0x1F
	orr r0, r0, #0x13
	/* disable IRQ FIQ */
	orr r0, r0, #0x60
	/* little endian */
	bic r0, r0, #0x1000
	msr cpsr, r0

	mrc p15, 0, r0, c1, c0, 0
	/* disable mmu */
	bic r0, r0, #(1 << 0)
	/* disable alignment fault */
	bic r0, r0, #(1 << 1)
	/* disable dcache */
	bic r0, r0, #(1 << 2)
	/* little endian operation */
	bic r0, r0, #(1 << 7)
	/* disable system protection */
	bic r0, r0, #(1 << 8)
	/* disable rom protection */
	bic r0, r0, #(1 << 9)
	/* disable icache */
	bic r0, r0, #(1 << 12)
	/* setup exception vector to 0xFFFF0000 ~ 0xFFFF001C */
	orr r0, r0, #(1 << 13)
	mcr p15, 0, r0, c1, c0, 0

	/* setup sp to SRAM A1 */
	ldr r0, =0x07FF8
	mov sp, r0

	/* load data from spinor flash to SRAM A1 */
	bl load_from_flash

	/* set boot source */
	mov r0, sp
	sub r0, r0, #4
	ldr r1, =0xFFFF4130
	str r1, [r0, #0]

	/* setup pc to SRAM A1 */
	mov pc, #0x0
