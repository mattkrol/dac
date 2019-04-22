#include "stm32f4xx.h"
#include <math.h>
#include <stdint.h>

#define LUT_SIZE 256
#define DAC_BITS 12

uint16_t lut_waveform[LUT_SIZE];
uint16_t acc;
uint16_t phi;
void lut_init(void){
    //calculate LUT values for a sin wave
    //scale and upward shift sin so the following conditions are met
    //sin(0) = (2^DAC_BITS-1)/2, sin(pi/2) = 2^DAC_BITS-1, sin(pi) = (2^DAC_BITS-1)/2, sin(3pi/2) = 0, ...
    //then quantize by adding 0.5 and truncating to uint16_t for dac
    for(uint16_t i = 0; i < LUT_SIZE; i++){
        lut_waveform[i] = (uint16_t)((sin(i*2*(M_PI/LUT_SIZE)) + 1)*(0xFFFF >> (16 - DAC_BITS))*0.5 + 0.5);
        //for sawtooth wave use the following code
        //lut_waveform[i] = (uint16_t)(i*(0xFFFF >> (16 - DAC_BITS))/LUT_SIZE + 0.5);
    }
}
void tim2_init(void){
    //enable clock on TIM2
    RCC->APB1ENR |= RCC_APB1ENR_TIM2EN; 
    //enable interrupts for TIM2 on the NVIC
    NVIC->ISER[0] |= (1 << TIM2_IRQn);
    //enable interrupts on TIM2 itself
    TIM2->DIER |= TIM_DIER_UIE;
    //set the timer speed so it overflows at a rate of 44.1 kHz
    //44077.13499 Hz is the closest we can get with a 16MHz system clock
    TIM2->PSC = 0;
    TIM2->ARR = 362;
    //enable TIM2
    TIM2->CR1 |= TIM_CR1_CEN;
}
void dac_init(void){
    //enable clock on DAC and PA
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    RCC->APB1ENR |= RCC_APB1ENR_DACEN;
    //set PA5 to analog mode
    GPIOA->MODER |= (3 << 10);
    //set PA5 output to very high speed
    GPIOA->OSPEEDR |= (3 << 10);
    //enable DAC2
    DAC->CR |= (1 << 16);
}
void TIM2_IRQHandler(void){
    //truncate rightmost 8 bits of acc and use it to get the lut value
    DAC->DHR12R2 = lut_waveform[acc >> 8];
    //increment accumulator by phase increment
    acc += phi;
    //clear the timer interrupt flag
    TIM2->SR &= ~1;
}
int main(void){
    //reset the accumulator
    acc = 0;
    //phase increment of 256 yields a 172 Hz wave
    phi = 256;
    //call init routines
    lut_init();
    dac_init();
    tim2_init();
    while(1);
    return 0;
}
