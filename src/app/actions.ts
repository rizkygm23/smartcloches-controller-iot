'use server'

const BLYNK_TOKEN = process.env.BLYNK_TOKEN;
const BLYNK_BASE_URL = 'https://blynk.cloud/external/api';

export async function setServoPosition(position: number) {
  if (!BLYNK_TOKEN) return { success: false, error: 'Token missing' };
  try {
    const response = await fetch(`${BLYNK_BASE_URL}/update?token=${BLYNK_TOKEN}&V4=${position}`);
    if (!response.ok) throw new Error('Failed to update servo position');
    return { success: true };
  } catch (error) {
    console.error(error);
    return { success: false, error: 'Connection failed' };
  }
}

export async function setServoSpeed(speed: number) {
  if (!BLYNK_TOKEN) return { success: false, error: 'Token missing' };
  try {
    const response = await fetch(`${BLYNK_BASE_URL}/update?token=${BLYNK_TOKEN}&V5=${speed}`);
    if (!response.ok) throw new Error('Failed to update servo speed');
    return { success: true };
  } catch (error) {
    console.error(error);
    return { success: false, error: 'Connection failed' };
  }
}

export async function getServoStatus() {
  if (!BLYNK_TOKEN) return { success: false, error: 'Token missing' };
  try {
    const response = await fetch(`${BLYNK_BASE_URL}/get?token=${BLYNK_TOKEN}&V4`, {
      cache: 'no-store'
    });
    if (!response.ok) throw new Error('Failed to get servo status');
    const data = await response.text();
    return { success: true, position: parseInt(data) };
  } catch (error) {
    console.error(error);
    return { success: false, error: 'Connection failed' };
  }
}
