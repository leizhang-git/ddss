<template>
  <div class="app-container finance-page">
    <el-card shadow="never" class="toolbar-card">
      <div class="toolbar">
        <div class="toolbar-group">
          <el-button v-hasPermi="['finance:add']" icon="el-icon-plus" plain size="mini" type="primary" @click="handleAdd">新增</el-button>
          <el-button v-hasPermi="['finance:edit']" :disabled="single" icon="el-icon-edit" plain size="mini" type="success" @click="handleUpdate">修改</el-button>
          <el-button v-hasPermi="['finance:remove']" :disabled="multiple" icon="el-icon-delete" plain size="mini" type="danger" @click="handleDelete">删除</el-button>
        </div>
        <el-divider direction="vertical"></el-divider>
        <div class="toolbar-group">
          <el-popover placement="bottom" width="200" trigger="click" title="列设置">
            <el-checkbox-group v-model="visibleCols">
              <el-checkbox v-for="c in allCols" :key="c.key" :label="c.key" style="display:block;margin:4px 0">{{ c.label }}</el-checkbox>
            </el-checkbox-group>
            <el-button slot="reference" icon="el-icon-menu" plain size="mini">列</el-button>
          </el-popover>
          <el-button icon="el-icon-refresh" plain size="mini" @click="getList">刷新</el-button>
          <el-button v-hasPermi="['finance:list']" icon="el-icon-download" plain size="mini" type="warning" @click="handleExport">导出</el-button>
        </div>
      </div>
    </el-card>

    <el-card shadow="never" class="table-card">
      <div class="table-wrapper">
        <el-table ref="table" v-loading="loading" :data="sortedList" stripe size="small"
          :height="tableHeight" show-summary :summary-method="getSummaries"
          @selection-change="handleSelectionChange" @sort-change="handleSort" :default-sort="{prop:'repaymentDay',order:'ascending'}">
          <el-table-column type="selection" width="55"/>
          <el-table-column label="名称" prop="creditorName" width="180" sortable="custom" fixed="left" show-overflow-tooltip v-if="vis('name')"/>
          <el-table-column label="便宜" width="100" sortable="custom" align="right" v-if="vis('cheap')"><template slot-scope="s"><span class="amt-positive">{{ cheap(s.row) }}</span></template></el-table-column>
          <el-table-column label="提前结清" prop="earlySettlementAmount" width="110" sortable="custom" align="right" v-if="vis('early')"/>
          <el-table-column label="总额" width="110" sortable="custom" align="right" v-if="vis('total')"><template slot-scope="s"><span class="amt-bold">{{ totalRepay(s.row) }}</span></template></el-table-column>
          <el-table-column label="日期" prop="repaymentStartDate" width="105" sortable="custom" align="center" v-if="vis('date')"/>
          <el-table-column label="几号" prop="repaymentDay" width="75" sortable="custom" align="center" v-if="vis('day')"/>
          <template v-if="vis('months')">
            <el-table-column v-for="m in months" :key="m" :label="m" width="88" align="center">
              <template slot-scope="s"><span :class="getCellVal(s.row,m)>0?'cell-val':'cell-zero'" @dblclick="startEdit(s.row,m)">{{ getCellVal(s.row,m)||0 }}</span></template>
            </el-table-column>
          </template>
          <el-table-column label="剩余" prop="remainingAmount" width="110" sortable="custom" align="right" v-if="vis('remain')"/>
          <el-table-column label="状态" width="70" align="center" fixed="right" v-if="vis('status')">
            <template slot-scope="s">
              <el-tag v-if="s.row.status==='0'" type="warning" size="mini" effect="plain">还款中</el-tag>
              <el-tag v-else-if="s.row.status==='1'" type="success" size="mini" effect="plain">已结清</el-tag>
              <el-tag v-else-if="s.row.status==='2'" type="danger" size="mini" effect="plain">逾期</el-tag>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-card>

    <el-dialog title="编辑金额" :visible.sync="cellEdit.open" width="300px" append-to-body>
      <el-form label-width="70px" @submit.native.prevent="saveCell">
        <el-form-item label="月份"><el-input :value="cellEdit.month" readonly/></el-form-item>
        <el-form-item label="金额"><el-input-number v-model="cellEdit.val" :min="0" :precision="2" style="width:100%" controls-position="right" ref="cellInput"/></el-form-item>
      </el-form>
      <div slot="footer"><el-button type="primary" @click="saveCell">保存</el-button><el-button @click="cellEdit.open=false">取消</el-button></div>
    </el-dialog>

    <el-dialog :title="formTitle" :visible.sync="formOpen" width="750px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="90px">
        <el-row :gutter="20">
          <el-col :span="12"><el-form-item label="名称" prop="creditorName"><el-input v-model="form.creditorName"/></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="总额"><el-input-number v-model="form.loanAmount" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/></el-form-item></el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="8"><el-form-item label="提前结清"><el-input-number v-model="form.earlySettlementAmount" :min="0" :precision="2" style="width:100%" controls-position="right"/></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="便宜"><el-input :value="cheap(form)" readonly style="font-weight:bold;color:#10b981"/></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="月还款"><el-input-number v-model="form.monthlyPayment" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/></el-form-item></el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="8"><el-form-item label="开始日期"><el-date-picker v-model="form.repaymentStartDate" type="date" value-format="yyyy-MM-dd" style="width:100%" @change="autoCalc"/></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="几号还"><el-input-number v-model="form.repaymentDay" :min="1" :max="31" style="width:100%" controls-position="right"/></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="期限(月)"><el-input-number v-model="form.loanTerm" :min="0" style="width:100%" controls-position="right" @change="autoCalc"/></el-form-item></el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="8"><el-form-item label="利率(%)"><el-input-number v-model="form.interestRate" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="利息总额"><el-input-number v-model="form.interestAmount" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="已还"><el-input-number v-model="form.paidAmount" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/></el-form-item></el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="8"><el-form-item label="剩余未还"><el-input-number v-model="form.remainingAmount" :min="0" :precision="2" style="width:100%" controls-position="right"/></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="状态" prop="status"><el-select v-model="form.status" style="width:100%"><el-option label="还款中" value="0"/><el-option label="已结清" value="1"/><el-option label="逾期" value="2"/></el-select></el-form-item></el-col>
        </el-row>
        <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" :rows="2"/></el-form-item>
      </el-form>
      <div slot="footer"><el-button type="primary" @click="submitForm">确定</el-button><el-button @click="formOpen=false">取消</el-button></div>
    </el-dialog>
  </div>
</template>

<script>
import { listFinance, getFinance, addFinance, updateFinance, delFinance, exportFinance } from '@/api/finance'

export default {
  name: 'Finance',
  data() {
    return {
      loading: false, formOpen: false, formTitle: '',
      financeList: [], ids: [], single: true, multiple: true, months: [], sortProp: 'repaymentDay', sortOrder: 'ascending',
      cellEdit: { open: false, row: null, month: '', val: 0 },
      allCols: [{key:'name',label:'名称'},{key:'cheap',label:'便宜'},{key:'early',label:'提前结清'},{key:'total',label:'总额'},{key:'date',label:'日期'},{key:'day',label:'几号'},{key:'months',label:'月份列'},{key:'remain',label:'剩余'},{key:'status',label:'状态'}],
      visibleCols: ['name','cheap','early','total','date','day','months','remain','status'],
      form: {},
      rules: { creditorName: [{ required: true, message: '必填', trigger: 'blur' }], status: [{ required: true, message: '必填', trigger: 'change' }] }
    }
  },
  computed: {
    tableHeight() {
      return Math.max(400, document.documentElement.clientHeight - 220)
    },
    sortedList() {
      if (!this.sortProp) return this.financeList
      const list = [...this.financeList]
      const p = this.sortProp, o = this.sortOrder === 'ascending' ? 1 : -1
      return list.sort((a,b) => {
        let va = p==='cheap' ? Number(this.cheap(a)) : (Number(a[p])||0)
        let vb = p==='cheap' ? Number(this.cheap(b)) : (Number(b[p])||0)
        return (va - vb) * o
      })
    }
  },
  created() { this.getList() },
  methods: {
    vis(k) { return this.visibleCols.includes(k) },
    cheap(row) { const t=Number(this.totalRepay(row))||0,e=Number(row.earlySettlementAmount)||0; return t&&e?Math.max(0,t-e).toFixed(2):'0' },
    totalRepay(row) {
      if (row._cachedTotal!=null) return row._cachedTotal
      let s=0; this.months.forEach(m=>{ s+=this.getCellVal(row,m) })
      const def=(Number(row.monthlyPayment)||0)*(row.loanTerm||0)
      row._cachedTotal=(s>0?s:def>0?def:0).toFixed(2)
      return row._cachedTotal
    },
    getCellVal(row, m) {
      const md = row._monthData||{}
      if (md[m]&&md[m].amt!=null) return Number(md[m].amt)
      const parts=m.split('-'), label=parts[parts.length-1]
      if (md[label]&&md[label].amt!=null) return Number(md[label].amt)
      return Number(this.payThisMonth(row,label))||0
    },
    payThisMonth(row, label) {
      const start=row.repaymentStartDate,day=row.repaymentDay,amt=row.monthlyPayment
      if(!start||!day||!amt) return 0
      const mon=parseInt(label); if(!mon) return 0
      const now=new Date(); const cy=now.getFullYear(),cm=now.getMonth()+1
      const tY=mon>=cm?cy:cy+1; const target=new Date(tY,mon-1,day)
      const sd=new Date(start),ed=new Date(start); ed.setMonth(ed.getMonth()+(row.loanTerm||0))
      return target>=sd&&target<=ed?Number(amt):0
    },
    startEdit(row, m) { this.cellEdit={open:true,row,month:m,val:this.getCellVal(row,m)} },
    saveCell() {
      const {row,month:m,val}=this.cellEdit; const v=Number(val)||0
      const idx=this.financeList.indexOf(row)
      if(!row._monthData) row._monthData={}
      if(!row._monthData[m]) row._monthData[m]={}
      row._monthData[m].amt=v
      row.monthData=JSON.stringify(row._monthData)
      let tp=0; this.months.forEach(mm=>{tp+=this.getCellVal(row,mm)})
      row.paidAmount=tp.toFixed(2)
      row.remainingAmount=Math.max(0,(Number(row.loanAmount)||0)-tp).toFixed(2)
      row._cachedTotal=null
      this.cellEdit.open=false
      if(idx>=0) this.$set(this.financeList, idx, {...row})
      updateFinance(row).catch(()=>{})
    },
    handleSort({prop,order}) { this.sortProp=prop; this.sortOrder=order },
    getList() {
      this.loading=true
      listFinance({pageNum:1,pageSize:999}).then(res=>{
        this.financeList=(res.rows||[]).map(r=>{let md={};try{md=JSON.parse(r.monthData||'{}')}catch(e){};return{...r,_monthData:md}})
        this.buildMonths(); this.loading=false
      })
    },
    buildMonths() {
      const now=new Date(); let max=new Date(now.getFullYear(),now.getMonth()+6,1)
      this.financeList.forEach(r=>{if(!r.repaymentStartDate||!r.loanTerm)return;const e=new Date(r.repaymentStartDate);e.setMonth(e.getMonth()+r.loanTerm);if(e>max)max=e})
      const ms=[]; const cur=new Date(now.getFullYear(),now.getMonth(),1)
      while(cur<=max){ms.push(cur.getFullYear().toString().slice(2)+'-'+(cur.getMonth()+1)+'月');cur.setMonth(cur.getMonth()+1)}
      this.months=ms
    },
    getSummaries({columns,data}) {
      const sums=columns.map(()=>''); sums[1]='合计'; let idx=2
      // 便宜
      let cheapSum=0; data.forEach(r=>{const tr=Number(this.totalRepay(r))||0,es=Number(r.earlySettlementAmount)||0;if(tr&&es)cheapSum+=Math.max(0,tr-es)}); sums[idx++]=cheapSum.toFixed(2)
      // 提前结清
      sums[idx++]=data.reduce((s,r)=>s+(Number(r.earlySettlementAmount)||0),0).toFixed(2)
      // 总额
      let totalSum=0; data.forEach(r=>totalSum+=Number(this.totalRepay(r))||0); sums[idx++]=totalSum.toFixed(2)
      // 日期
      idx++
      // 几号
      idx++
      // 月份列
      this.months.forEach(m=>{let mt=0;data.forEach(r=>{mt+=this.getCellVal(r,m)});sums[idx++]=mt>0?mt.toFixed(2):''})
      // 剩余
      sums[idx++]=data.reduce((s,r)=>s+(Number(r.remainingAmount)||0),0).toFixed(2)
      return sums
    },
    handleSelectionChange(sel){this.ids=sel.map(i=>i.financeId);this.single=sel.length!==1;this.multiple=!sel.length},
    handleAdd(){this.form={status:'0'};this.formOpen=true;this.formTitle='新增'},
    handleUpdate(){if(!this.ids.length){this.$message.warning('请先选中');return};getFinance(this.ids[0]).then(res=>{this.form=res.data;this.formOpen=true;this.formTitle='修改'})},
    submitForm(){this.$refs.form.validate(v=>{if(!v)return;const act=this.form.financeId?updateFinance:addFinance;act(this.form).then(()=>{this.$message.success('成功');this.formOpen=false;this.$nextTick(()=>this.getList())})})},
    handleDelete(){if(!this.ids.length){this.$message.warning('请先选中');return};this.$modal.confirm('确认删除？').then(()=>delFinance(this.ids.join(','))).then(()=>{this.getList();this.$message.success('已删除')})},
    handleExport(){exportFinance().then(res=>{const blob=new Blob([res]);const a=document.createElement('a');const url=URL.createObjectURL(blob);a.href=url;a.download='财务管理.xlsx';a.click();setTimeout(()=>URL.revokeObjectURL(url),0);this.$message.success('导出成功')}).catch(()=>{this.$message.error('导出失败')})},
    autoCalc(){
      const f=this.form;const L=Number(f.loanAmount)||0,P=Number(f.paidAmount)||0,R=Number(f.interestRate)||0,T=f.loanTerm||0,M=Number(f.monthlyPayment)||0,I=Number(f.interestAmount)||0
      if(L&&P)f.remainingAmount=Math.max(0,L-P).toFixed(2)
      if(L&&R&&T)f.interestAmount=(L*(R/100)*(T/12)).toFixed(1)
      if(L&&I&&T)f.monthlyPayment=Number(((L+I)/T).toFixed(2))
      if(M&&T&&L&&!I)f.interestAmount=(M*T-L>0?M*T-L:0).toFixed(1)
      if(f.repaymentStartDate&&T){const d=new Date(f.repaymentStartDate);d.setMonth(d.getMonth()+T);f.repaymentEndDate=d.toISOString().slice(0,10)}
    }
  }
}
</script>

<style scoped>
.finance-page {
  .toolbar-card {
    margin-bottom: 12px;
    border-radius: 10px;
    border: none;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);

    .toolbar {
      display: flex;
      align-items: center;
      gap: 8px;

      .toolbar-group {
        display: flex;
        align-items: center;
        gap: 6px;
      }
    }
  }

  .table-card {
    border-radius: 10px;
    border: none;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);

    .table-wrapper {
      overflow-x: auto;
    }
  }

  ::v-deep .el-table {
    border-radius: 8px;

    th {
      background: #f9fafb;
      color: #374151;
      font-weight: 600;
    }

    .el-table__footer-wrapper td {
      font-weight: 700;
      font-size: 13px;
      background: #f3f4f6;
      color: #1f2937;
    }
  }

  .amt-positive {
    color: #10b981;
    font-weight: 500;
  }
  .amt-bold {
    font-weight: 600;
    color: #1f2937;
  }

  .cell-val {
    cursor: pointer;
    color: #1f2937;
    padding: 2px 8px;
    border-radius: 4px;
    transition: all 0.2s;

    &:hover {
      color: #4f46e5;
      background: rgba(79, 70, 229, 0.08);
    }
  }

  .cell-zero {
    cursor: pointer;
    color: #d1d5db;
    padding: 2px 8px;
    border-radius: 4px;
    transition: all 0.2s;

    &:hover {
      color: #4f46e5;
      background: rgba(79, 70, 229, 0.08);
    }
  }

  ::v-deep .el-dialog {
    border-radius: 14px;
  }

  ::v-deep .el-dialog__header {
    border-bottom: 1px solid #f3f4f6;
    padding-bottom: 14px;
  }

  ::v-deep .el-dialog__footer {
    border-top: 1px solid #f3f4f6;
    padding-top: 14px;
  }
}
</style>
