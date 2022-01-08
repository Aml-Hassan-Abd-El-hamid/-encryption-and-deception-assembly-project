#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>


void encrypt (uint16_t v[2], const uint16_t k[4]) {
   uint16_t v0=v[0], v1=v[1],sum=0;
   uint16_t delta=0x0130;
   uint16_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];

   for (int i=0; i<32; i++) {                         /* basic cycle start */
        sum += delta;
        v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
    }
        v[0]=v0; v[1]=v1;

        printf("%"PRIu16"\n",v[0]);
        printf("%"PRIu16"\n",v[1]);

}

void decrypt (uint16_t v[2], const uint16_t k[4]) {
   uint16_t v0=v[0], v1=v[1];
   uint16_t sum=(0x0130<<5) & 0xFFFF ;
   uint16_t delta=0x0130;
   uint16_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];

   for (int i=0; i<32; i++) {                         /* basic cycle start */
        v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        sum -= delta;
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;

        printf("%"PRIu16"\n",v[0]);
        printf("%"PRIu16"\n",v[1]);
}
int main()
{
  uint16_t v[2]={10325,20123};
  //uint16_t c[2]={62269,18100};
  uint16_t k[4]={1,2,3,4};

  printf("%"PRIu16"\n",v[0]);
  printf("%"PRIu16"\n",v[1]);
  encrypt(v,k);
  printf("*********\n");
  //uint16_t temp=d[0];
  //d[0]=d[1];
  //d[1]=temp;
  decrypt(v,k);

   return 0;
}
