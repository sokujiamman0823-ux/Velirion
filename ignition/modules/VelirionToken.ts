import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const VelirionTokenModule = buildModule("VelirionTokenModule", (m) => {
  const token = m.contract("VelirionToken");

  return { token };
});

export default VelirionTokenModule;
